#!/bin/bash

BASE_URL="https://ebooksplan.club/"
BOOK_DIR_URL=`echo $BASE_URL"?dir=%E6%AF%8F%E5%91%A8%E4%B8%80%E4%B9%A6"`

STORE_DIR="/home/lm/books"

cd $STORE_DIR

DOWNLOAD_BOOK()
{
    DIR=`echo $STORE_DIR"/"$1`
    STR=`echo $2 | sed s/[[:space:]]//g`
    ARR=(${STR//\"/ })
    filename=${ARR[1]}
    if [[ $filename == ".." ]];then
        return
    fi
    
    echo "=> Start download $filename ..."

    downloadurl=`echo $BASE_URL${ARR[3]}`
    filepath=`echo $DIR"/"$filename`
    echo $filepath
    if [[ ! -f $filepath ]];then
        wget -O $filepath $downloadurl
        if [[ $? -ne 0 ]];then
            echo "=> Download $filename failed."
        else
            echo "=> Download $filename success."
            sleep 5
        fi
    else
        echo "=> $filename exist. Skip."
    fi
}

GET_BOOK()
{
    bookname=$1
    if [[ ! -d $bookname ]];then
        mkdir $bookname
    else
        echo "=> Dir $bookname Exist. Skip."
    fi
    dirurl=`echo $BASE_URL$2`
    curl $dirurl | grep 'li data-name="' | while read line; do DOWNLOAD_BOOK "$bookname" "$line"; done
}

COUNT=1
GET_DIR()
{
    STR=`echo $1 | sed s/[[:space:]]//g`
    COUNT=`expr $COUNT + 1`
    ARR=(${STR//\"/ })
    bookname=${ARR[1]}
    subdirurl=${ARR[3]}
    GET_BOOK $bookname $subdirurl
    
    echo ""
}

echo "=> "`date`". Start sync book."
curl $BOOK_DIR_URL | grep 'li data-name="week' | while read line; do GET_DIR "$line"; done
echo "=> "`date`". End sync book."
echo ""
echo ""
#-- push to server --#
echo "=> "`date`". Start push to server."
cd $STORE_DIR
git add .
git commit -m "update"
git push
if [[ $? -ne 0 ]];then
    echo "=> Push to server failed."
else
    echo "=> Push to server success."
fi
