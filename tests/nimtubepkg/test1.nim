import nimtube

describe "findVideoTitle":
  test "Finds a video title from its URL":
    let title = findVideoTitle("https://www.youtube.com/watch?v=8ptH79R53c0")
    doAssert title == "New Voxel Engine Reveal - Crystal Islands Experiment"

describe "findVideoTitleFromID":
  test "Throws if there is an error":
    assertRaises(Exception, "index out of bounds, the container is empty"):
      discard findVideoTitleFromID("aoeuaoeuoaeu")

describe "parseVideoID":
  test "Returns a valid video ID if the URL is a video":
    let id = parseVideoID("https://www.youtube.com/watch?v=8ptH79R53c0")
    doAssert id == "8ptH79R53c0"

  test "Returns a valid video ID if the (short) URL is a video":
    let id = parseVideoID("https://youtu.be/dQw4w9WgXcQ")
    doAssert id == "dQw4w9WgXcQ"

  test "Returns none if the URL is not a video":
    doAssert parseVideoID("https://www.youtube.com/").len == 0

