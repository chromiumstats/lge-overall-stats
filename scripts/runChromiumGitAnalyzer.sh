#!/bin/bash

# Define pathes for this tool and Chromium source.
CHROMIUM_PATH=$HOME/chromium/Chromium
OUTPUT_PATH=$HOME/github/cr-stats-per-company/cr-stats-per-companies
GIT_STATS_PATH=$HOME/github/cr-stats-per-company/cr-stats-tool/bin/git_stats

export CHROMIUM_EMAIL="@chromium.org"
export GOOGLE_EMAIL="@google.com"
export WEBKIT_EMAIL="@webkit.org"
export APPLE_EMAIL="@apple.com"
export OPERA_EMAIL="@opera.com"
export SAMSUNG_EMAIL="@samsung.com"
export INTEL_EMAIL="@intel.com"
export GMAIL_EMAIL="@gmail.com"
export NOKIA_EMAIL="@nokia.com"
export YANDEX_EMAIL="@yandex-team.ru"
export IGALIA_EMAIL="@igalia.com"
export ADOBE_EMAIL="@adobe.com"
export AMAZON_EMAIL="@amazon.com"
export NVIDIA_EMAIL="@nvidia.com"
export NAVER_EMAIL="@navercorp.com"
export LGE_EMAIL="@lge.com"
export CISCO_EMAIL="@cisco.com"
export TENCENT_EMAIL="@tencent.com"
export ARM_EMAIL="@arm.com"
export COLLABORA_EMAIL="@collabora.com"
export NETFLIX_EMAIL="@netflix.com"
export HUAWEI_EMAIL="@huawei.com"
export IBM_EMAIL="@ca.ibm.com"
export AMD_EMAIL="@amd.com"
export IBM_EMAIL="@ca.ibm.com"

while :
do
    # Update Chromium source code.
    start_timestamp=$(date +"%T")
    timestamp=$start_timestamp
    echo "[$timestamp] Start updating  Chromium trunk, please wait..."
    cd $CHROMIUM_PATH
    git pull origin master:master
    git subtree add --prefix=v8-log https://chromium.googlesource.com/v8/v8.git master
    git subtree add --prefix=pdfium-log https://pdfium.googlesource.com/pdfium master
    timestamp=$(date +"%T")
    echo "[$timestamp] Finish to update Chromium."

    # Start to analyze commit counts.
    now="$(date +'%Y-%m-%d')"
    timestamp=$(date +"%T")
    echo "[$timestamp] Starting checking company commits until $now, please wait..."
    git filter-branch -f --commit-filter '
        if echo "$GIT_AUTHOR_EMAIL" | grep -q "$CHROMIUM_EMAIL\|$GOOGLE_EMAIL\|$WEBKIT_EMAIL\|$APPLE_EMAIL\|$OPERA_EMAIL\|$SAMSUNG_EMAIL\|$INTEL_EMAIL\|$GMAIL_EMAIL\|$NOKIA_EMAIL\|$YANDEX_EMAIL\|$IGALIA_EMAIL\|$ADOBE_EMAIL\|$AMAZON_EMAIL\|$NVIDIA_EMAIL\|$NAVER_EMAIL\|$LGE_EMAIL\|$CISCO_EMAIL\|$TENCENT_EMAIL\|$ARM_EMAIL\|$COLLABORA_EMAIL\|$NETFLIX_EMAIL\|$HUAWEI_EMAIL\|$IBM_EMAIL\|$AMD_EMAIL\|$IBM_EMAIL";
        then
            git commit-tree "$@";
        else
            skip_commit "$@";
        fi' HEAD

    timestamp=$(date +"%T")
    echo "[$timestamp] Finish to find each company commits."

    $GIT_STATS_PATH generate -p $CHROMIUM_PATH -o $OUTPUT_PATH

    # Restore master branch
    git reset --hard refs/original/refs/heads/master
    git reset --hard HEAD~2

    # Upload the result to github.
    cd $OUTPUT_PATH
    git add .
    git commit -m "Update the new result by bot"
    git fetch origin master
    git rebase origin/master
    git push origin master:master

    timestamp=$(date +"%T")
    echo "[$timestamp] Finish to upload new result!"
    echo "- StartTime: $start_timestamp"
    echo "- EndTime: $timestamp"
done
