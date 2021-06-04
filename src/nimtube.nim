import
  httpclient,
  json,
  strformat,
  uri,
  os,
  re,
  options

# See https://developers.google.com/youtube/v3/docs#Videos

type SearchResult* = tuple[title: string, url: string]

const
  apiEndpoint = "https://www.googleapis.com/youtube/v3"
  youtubeURLPrefix = "https://www.youtube.com/watch?v="

let
  apiKey = getEnv("YOUTUBE_API_KEY", "")
  youtubeVidIDRegex = re""".*(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?/\s]{11}).*"""

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

proc parseVideoID*(videoURL: string): string =
  ## @return {string} The video id based on a URL, or an empty string if not found.
  if videoURL =~ youtubeVidIDRegex:
    for match in matches:
      if match.len > 0:
        return match

proc findVideoTitleFromID*(videoID: string): string =
  ## @return {string} The video title based on its id, or an empty string if not found.
  let client = newHttpClient()
  try:
    let response = get(client, fmt"{apiEndpoint}/videos?part=snippet&id={videoID}&key={apiKey}")
    let jsonData = parseJson($response.body)
    let firstItem = jsonData["items"].elems[0]
    return firstItem["snippet"]["localized"]["title"].getStr
  except:
    # TODO: Propagate exceptions
    raise
  finally:
    client.close()

proc findVideoTitle*(videoURL: string): string =
  ## @return {string} The video title based on a video URL, or an empty string if not found.
  let id = parseVideoID(videoURL)
  if id.len > 0:
    return findVideoTitleFromID(id)

when isMainModule:
  let videoURL = "https://www.youtube.com/watch?v=8ptH79R53c0"
  let title = parseVideoID(videoURL)
  echo title

