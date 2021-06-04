import
  httpclient,
  json,
  strformat,
  strutils,
  uri,
  os

# See https://developers.google.com/youtube/v3/docs#Videos

type SearchResult* = tuple[title: string, url: string]

const
  apiEndpoint = "https://www.googleapis.com/youtube/v3"
  youtubeURLPrefix = "https://www.youtube.com/watch?v="

let apiKey = getEnv("YOUTUBE_API_KEY", "")

template toYoutubeURL(videoId: string): string = youtubeURLPrefix & videoId

proc getSearchResults*(searchQuery: string): seq[SearchResult] =
  # Using Invidious API to retrieve the search results but playing the results directly from YouTube.
  let queryParam = encodeUrl(searchQuery)
  let client = newHttpClient()
  try:
    let
      response = get(client, fmt"{apiEndpoint}/search?part=id%2Csnippet&q={queryParam}&key={apiKey}")
      jsonData = parseJson($response.body)
      items = jsonData["items"]
    for item in items:
      let id = item["id"]
      if id.hasKey("videoId"):
        let title = item["snippet"]["title"].getStr
        let videoId = id["videoId"].getStr
        result.add((title, toYoutubeURL(videoId)))
  except: discard
  finally: client.close()

proc findVideoTitle*(videoURL: string): string =
  let client = newHttpClient()
  let videoURLSplit = videoURL.split('=')
  if videoURLSplit.len < 2:
    raise newException(Exception, "Invalid YouTube video URL")

  let videoID = videoURLSplit[1]
  try:
    let response = get(client, fmt"{apiEndpoint}/videos?part=snippet&id={videoID}&key={apiKey}")
    let jsonData = parseJson($response.body)
    let firstItem = jsonData["items"].elems[0]
    return firstItem["snippet"]["localized"]["title"].getStr
  except:
    echo getCurrentExceptionMsg()
    raise
  finally: client.close()

when isMainModule:
  let title = findVideoTitle("https://www.youtube.com/watch?v=8ptH79R53c0")
  echo title

