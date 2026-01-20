# Sample API callouts

The app uses two external services: <code>OpenAI</code> and <code>ConvertAPI</code>. Below you can find sample API callouts to each of them.

## OpenAI

OpenAI documentation [here](https://platform.openai.com/docs/api-reference/chat/create). Below you can find the request details and sample response.

<table>
  <tr><td><strong>Endpoint</strong></td><td><code>https://api.openai.com/v1/chat/completions</code></td></tr>
  <tr><td><strong>Method</strong></td><td><code>POST</code></td></tr>
  <tr><td><strong>Headers</strong></td><td><pre>
  “Content-Type: application/json”
  “Authorization: Bearer {API_key} // API_key - OpenAI Secret API key</pre></td></tr>
  <tr><td><strong>Sample Body</strong></td><td>
  <pre>
{
   "temperature":0.0,
   "model":"gpt-4",
   "messages":[
      {
         "role":"system",
         "content":"You are a helpful assistant who answers user's questions regarding provided document..."
      },
      {
         "role":"user",
         "content":"What this document is about??"
      }
   ]
}
  </pre></td></tr>
  <tr><td><strong>Sample Response</strong></td><td>
<pre>
{
   "id":"chatcmpl-7jm1jpLz6y74qIPVIi14ACyioBJG9",
   "object":"chat.completion",
   "created":1691143731,
   "model":"gpt-4",
   "choices":[
      {
         "index":0,
         "message":{
            "role":"assistant",
            "content":"This document is about sharing architecture in Salesforce..."
         },
         "finish_reason":"stop"
      }
   ],
   "usage":{
      "prompt_tokens":1356,
      "completion_tokens":278,
      "total_tokens":1634
   }
}</pre></td></tr>
</table>





## Extractor API

Extractor API documentation [here](https://extractorapi.com/docs/#/paths/~1pdf-extractor/post). Below you can find the request details and sample response.

<table>
  <tr><td><strong>Endpoint</strong></td><td><code>https://extractorapi.com/api/v1/pdf-extractor</code></td></tr>
  <tr><td><strong>Method</strong></td><td><code>POST</code></td></tr>
  <tr><td><strong>Headers</strong></td><td><pre>
  “Content-Type: multipart/form-data; charset="UTF-8"; boundary="1ff13444ed8140c7a32fc4e6451aa76d"”
  “apikey: {apiKey}” </pre></td></tr>
  <tr><td><strong>Sample Body</strong></td><td>
  <pre>
Multipart Form
</pre></td></tr>
  <tr><td><strong>Sample Response</strong></td><td>
<pre>
{
  "data": "Home Health  | 02 August 2021     3 \n  \nExhibit 3: Continuum of Care  \nHome care setting are lowest cost...."
}
</pre></td></tr>
</table>