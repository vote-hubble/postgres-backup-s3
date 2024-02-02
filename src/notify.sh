if [ -n "$CALLBACK_URL" ]; then
  message="$1"
  curl -X POST -H "Content-Type: application/json" -d "{\"text\": \"${message}\"}" $CALLBACK_URL
fi
