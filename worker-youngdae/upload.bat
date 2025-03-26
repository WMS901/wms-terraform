@echo off
setlocal

REM AWS CLI로 S3 업로드 (전체 디렉터리 동기화)
aws s3 sync "C:\frontfile" s3://frontend-page --acl public-read

echo --------------------------------------
echo Files from C:\frontfile have been uploaded to S3!
pause
