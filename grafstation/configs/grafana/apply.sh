#!/opt/homebrew/bin/bash

# set -x

TIMESTAMP=$(date "+%s")

JQ="/opt/homebrew/bin/jq"
TF="/opt/homebrew/bin/terraform"

ABEMA_JWT_TOKEN=${ABEMA_JWT_TOKEN:-""}

ABEMA_SLOTS_FILE="/tmp/abema_slots.json"
JRA_RACE_JSON="/tmp/jra_races.json"
DIRT_RACE_JSON="/tmp/dirt_races.json"

TFVARS=(
  is_tv_channel1_muted
  is_tv_channel2_muted
  is_youtube_muted
  is_daymode
  is_newstime_domestic
  is_newstime_global
  is_racetime
  is_refreshtime
  is_stream_onair
  is_earthquake
)
TF_OPTIONS=${TERRAFORM_OPTIONS:-"-auto-approve -var-file=/tmp/gchls.tfvars"}

# ABEMAの番組表をバックアップする
function fetch_abema_slots_data() {
  local token=${1:?}
  local timetable_url="https://api.p-c3-e.abema-tv.com/v1/timetable/dataSet?debug=false"
  local filepath=${ABEMA_SLOTS_FILE}

  if [[ ! -e "${ABEMA_SLOTS_FILE}" ]] || [[ $(date "+%M") == "00" ]]; then
    local onair_slot=$(curl -o - -q -L \
      -H "Accept-Encoding: gzip" \
      -H "Authorization: Bearer ${token}" "${timetable_url}" \
      | gunzip)
    echo ${onair_slot} > ${filepath}
  fi
}

# 中央競馬レース情報を取得する
function fetch_jra_race_data() {
  local yyyymm=${1:-$(date "+%Y%m")}
  local jra_json_url="https://jra.jp/keiba/common/calendar/json/"

  if [[ ! -e "${JRA_RACE_JSON}" ]] || [[ $(date "+%M") == "00" ]]; then
    curl -s -o "${JRA_RACE_JSON}" "${jra_json_url}/${yyyymm}.json"
  fi
}

# ダートレース情報を取得する
function fetch_dirt_race_data() {
  if [[ ! -e "${DIRT_RACE_JSON}" ]] || [[ $(date "+%M") == "00" ]]; then
    curl -s -o "${DIRT_RACE_JSON}" "https://jra.event.lkj.io/graderaces_dirtgrade.json"
  fi
}

# Mリーグをやっているか確認する
function is_mleague_onair() {

  local now_unixtime=${TIMESTAMP}
  local filepath=${ABEMA_SLOTS_FILE}

  local mleague_onair_slot=$(cat ${filepath} \
    | ${JQ} -r ".slots[] \
      | select( .channelId == \"mahjong\" and .mark.live == true ) \
      | select(.title | contains(\"Mリーグ\") ) \
      | select(.startAt < ${now_unixtime} and .endAt > ${now_unixtime} ) \
      | .id")
    if [[ ${mleague_onair_slot} != "" ]]; then
      return 0
    else
      return 1
    fi
}

# 中央競馬をやっている日か確認する
function is_national_raceday(){
  local day=${1:-$(date "+%-d")}
  local num=0

  num=$(cat ${JRA_RACE_JSON} \
    | ${JQ} -r ".[].data[] | select(.date==\"${day}\") | .info[].race | length"
  )

  if [[ "${num}" == "" ]]; then
    num=0
  fi
  if [[ ${num} > 0 ]]; then
    return 0
  else
    return 1
  fi
}

# ダートグレード競走をやっているか確認する
function is_dirt_grade_race() {
  local num=0

  num=$(cat ${DIRT_RACE_JSON} \
    | ${JQ} -r "[.races[] | select(.start_at - ${TIMESTAMP} < 3600 and .end_at + 900 > ${TIMESTAMP})] | length"
  )

  if [[ "${num}" == "" ]]; then
      num=0
    fi
    if [[ ${num} > 0 ]]; then
      return 0
    else
      return 1
    fi
}

# 地震がなかったか確認する
# https://www.p2pquake.net/develop/
function check_latest_earthquake() {
  echo $(curl -s "https://api.p2pquake.net/v2/history?codes=556&limit=1" \
    | ${JQ} -r ".[].time \
      | split(\".\")[0] \
      | strptime(\"%Y/%m/%d %H:%M:%S\") \
      | strftime(\"%s\")" \
  )
}

function main(){

  echo "---------------------------------"
  date "+%Y/%m/%d %H:%M:%S"

  # 外部データ取得処理
  fetch_abema_slots_data "${ABEMA_JWT_TOKEN}"
  fetch_jra_race_data
  fetch_dirt_race_data

  # 曜日・時間を取得
  weekday=$(date +%u) # 月-日 = 1-7
  hour=$(date +%-H)
  min=$(date +%-M)
  now=$(echo "scale=3; ${hour} + (${min} / 60)" | bc)

  echo "today: weekday"
  echo "now: ${now}"

  # 0:00~05:45 / 停止
  if [ $( echo "${now} < 5.75" | bc ) == 1 ]; then
    :

  # 5:45~06:30 / ミュート解除
  elif [ $( echo "${now} < 6.5" | bc ) == 1 ]; then
    is_youtube_muted=false

  # 6:30~06:35 / ストレッチ
  elif [ $( echo "${now} < 6.583" | bc ) == 1 ]; then
    is_refreshtime=true

  # 07:00~07:55 / ミュート解除
  elif [ $( echo "${now} < 7.916" | bc ) == 1 ]; then
    is_youtube_muted=false

  # 07:55~09:55 / BGMのみ
  elif [ $( echo "${now} < 9.916" | bc ) == 1 ]; then
    is_tv_channel1_muted=false

  # 09:55~10:00 / ストレッチ
  elif [ $( echo "${now} < 10" | bc ) == 1 ]; then
    is_refreshtime=true

  # 10:00~12:00 / 停止
  elif [ $( echo "${now} < 12" | bc ) == 1 ]; then
    :

  ## 12:00~12:20 / ニュース(国内)
  elif [ $( echo "${now} < 12.33" | bc ) == 1 ]; then
    is_newstime_domestic=true
    is_tv_channel1_muted=false

  # 12:20~12:40 / ニュース(国外)
  elif [ $( echo "${now} < 12.66" | bc ) == 1 ]; then
    is_newstime_global=true
    is_tv_channel1_muted=false

  # 12:40~12:55 / 停止
  elif [ $( echo "${now} < 12.916" | bc ) == 1 ]; then
    :

  # 12:55~13:00 / ストレッチ
  elif [ $( echo "${now} < 13" | bc ) == 1 ]; then
    is_refreshtime=true

  # 13:00~15:00 / 停止
  elif [ $( echo "${now} < 15" | bc ) == 1 ]; then
    :

  # 15:00~15:05 / ストレッチ
  elif [ $( echo "${now} < 15.083" | bc ) == 1 ]; then
    is_refreshtime=true

  # 15:05~18:55 / 停止
  elif [ $( echo "${now} < 18.916" | bc ) == 1 ]; then
    :

  # 18:55~19:00 / ストレッチ
  elif [ $( echo "${now} < 19" | bc ) == 1 ]; then
    is_refreshtime=true

  # 19:00~22:30 / メインチャンネルのミュートを解除
  elif [ $( echo "${now} < 22.5" | bc ) == 1 ]; then
    is_tv_channel1_muted=false

  ## 22:30~24:00 / 停止
  else
    :
  fi

  # Mリーグの放送中はStreamlinkをつける
  if is_mleague_onair; then
    echo "Mリーグが放送されています!"
    is_stream_onair=true
    is_tv_channel1_muted=false
    is_youtube_muted=true
  fi

  # 中央競馬の放送日は9:00〜17:00までグリーンチャンネルに変更する
  if is_national_raceday; then
    echo "中央競馬の開催日です!"

    if [ $( echo "${now} < 9" | bc ) == 1 ]; then
      :
    elif [ $( echo "${now} < 17" | bc ) == 1 ]; then
      is_racetime=true
      is_tv_channel1_muted=false
      is_youtube_muted=true
    else
      :
    fi
  fi

  # ダート重賞番組が放送されている場合、強制的にチャンネルをグリーンチャンネルに変更する
  if is_dirt_grade_race; then
    echo "ダート重賞が始まります!"
    is_racetime=true
    is_tv_channel1_muted=false
    is_youtube_muted=true
  fi

  # 直近で緊急地震速報が発生している場合、強制的にチャンネルをニュースに変更する
  latest_earthquake_tsux=$(check_latest_earthquake)
  latest_earthquake_offset=$(( TIMESTAMP - latest_earthquake_tsux ))
  if (( ${latest_earthquake_offset} < 3600 )); then
    echo "!!! 直近で緊急地震速報が発報されています（ニュースをONにします）!!!"
    is_earthquake=true
    is_tv_channel1_muted=false

    # TODO: ここでテレビ自体のONも挟みたい
  fi

  # 05:45~17:30までを日中として判定
  if [ $( echo "${now} > 5.83" | bc ) == 1 ] && [ $( echo "${now} < 17.5" | bc ) == 1 ]; then
    echo "時間帯: 昼"
    is_daymode=true
  else
    echo "時間帯: 夜"
  fi

  # デフォルト外項目のみterraformに変数として渡す
  for var in ${TFVARS[@]}; do
    if [[ -n "${!var}" ]]; then
      echo "${var}: ${!var}"
      export TF_VAR_${var^^}=${!var}
    fi
  done

  # 設定反映(org/adminをimportしてない場合は再度importする)
  ${TF} init -upgrade

  is_exist_admin=$(${TF} state list grafana_user.admin)
  is_exist_main=$(${TF} state list grafana_organization.main)
  if [[ "${is_exist_admin}" == "" ]]; then
    ${TF} import grafana_user.admin 1
  fi
  if [[ "${is_exist_main}" == "" ]]; then
    ${TF} import grafana_organization.main 1
  fi

  ${TF} apply ${TF_OPTIONS}

  # 現在時刻のtfstateをバックアップする
  if [[ $(date "+%M") == "00" ]]; then
    mkdir -p ${HOME}/tfstate.bak
    ts=$(date "+%Y%m%d%H%M")
    cp /tmp/terraform.tfstate ${HOME}/tfstate.bak/terraform.tfstate.${ts}
  fi

}

main $@
