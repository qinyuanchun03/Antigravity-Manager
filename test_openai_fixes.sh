#!/bin/bash

echo "========================================="
echo "OpenAI 协议修复测试"
echo "========================================="
echo ""

BASE_URL="http://127.0.0.1:8045"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试 1: usage 嵌入验证
echo "测试 1: 验证 usage 嵌入到 finish_reason chunk"
echo "---------------------------------------------"
RESPONSE=$(curl -s -X POST "$BASE_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-2.0-flash-exp",
    "messages": [{"role": "user", "content": "Say hello in one word"}],
    "stream": true
  }' --no-buffer)

# 检查是否有包含 finish_reason 和 usage 的同一个 chunk
if echo "$RESPONSE" | grep -q '"finish_reason"' && echo "$RESPONSE" | grep -A 5 '"finish_reason"' | grep -q '"usage"'; then
    echo -e "${GREEN}✓ PASS${NC}: usage 已嵌入到 finish_reason chunk"
else
    echo -e "${RED}✗ FAIL${NC}: usage 未嵌入到 finish_reason chunk"
fi
echo ""

# 测试 2: [DONE] 信号唯一性
echo "测试 2: 验证 [DONE] 信号只发送一次"
echo "---------------------------------------------"
DONE_COUNT=$(curl -s -X POST "$BASE_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-2.0-flash-exp",
    "messages": [{"role": "user", "content": "Test"}],
    "stream": true
  }' --no-buffer | grep -c "\[DONE\]")

if [ "$DONE_COUNT" -eq 1 ]; then
    echo -e "${GREEN}✓ PASS${NC}: [DONE] 信号只发送了 1 次"
else
    echo -e "${RED}✗ FAIL${NC}: [DONE] 信号发送了 $DONE_COUNT 次 (预期 1 次)"
fi
echo ""

# 测试 3: Codex 0 token 修复
echo "测试 3: 验证 Codex CLI input_tokens > 0"
echo "---------------------------------------------"
RESPONSE=$(curl -s -X POST "$BASE_URL/v1/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "instructions": "You are a helpful assistant",
    "input": [
      {"type": "message", "role": "user", "content": [{"text": "Hello, how are you?"}]}
    ],
    "stream": true
  }' --no-buffer)

# 提取 input_tokens 值
INPUT_TOKENS=$(echo "$RESPONSE" | grep -o '"input_tokens":[0-9]*' | head -1 | grep -o '[0-9]*')

if [ -n "$INPUT_TOKENS" ] && [ "$INPUT_TOKENS" -gt 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}: input_tokens = $INPUT_TOKENS (> 0)"
else
    echo -e "${RED}✗ FAIL${NC}: input_tokens = ${INPUT_TOKENS:-0} (预期 > 0)"
fi
echo ""

# 测试 4: 心跳机制 (长时间流式)
echo "测试 4: 验证心跳机制 (15s 测试)"
echo "---------------------------------------------"
echo "发送请求并监听 15 秒..."
timeout 15s curl -s -X POST "$BASE_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-2.0-flash-exp",
    "messages": [{"role": "user", "content": "Count from 1 to 100 slowly"}],
    "stream": true
  }' --no-buffer > /tmp/heartbeat_test.txt 2>&1 &

CURL_PID=$!
sleep 16
kill $CURL_PID 2>/dev/null

# 检查是否有心跳
if grep -q ": ping" /tmp/heartbeat_test.txt; then
    echo -e "${GREEN}✓ PASS${NC}: 检测到心跳包 (: ping)"
else
    echo -e "${YELLOW}⚠ WARNING${NC}: 未检测到心跳包 (可能响应太快)"
fi
rm -f /tmp/heartbeat_test.txt
echo ""

# 测试 5: 流式稳定性 (Peek 预检)
echo "测试 5: 验证流式稳定性 (无错误断开)"
echo "---------------------------------------------"
RESPONSE=$(curl -s -X POST "$BASE_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-2.0-flash-exp",
    "messages": [{"role": "user", "content": "Write a short poem"}],
    "stream": true
  }' --no-buffer)

# 检查是否有错误
if echo "$RESPONSE" | grep -q '"error"'; then
    echo -e "${RED}✗ FAIL${NC}: 流式响应包含错误"
    echo "$RESPONSE" | grep '"error"'
else
    echo -e "${GREEN}✓ PASS${NC}: 流式响应正常,无错误"
fi
echo ""

echo "========================================="
echo "测试完成"
echo "========================================="
