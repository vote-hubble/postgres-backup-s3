if [ $# -eq 1 ]; then
  message="$0"
  curl -X POST -H "Content-Type: application/json" -d "{\"text\": \"${message}\"}" $CALLBACK_URL
fi
