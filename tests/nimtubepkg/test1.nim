import nimtube

describe "Tests the nimtube API":
  test "Finds a video title from its URL":
    let title = findVideoTitle("https://www.youtube.com/watch?v=8ptH79R53c0")
    doAssert title == "New Voxel Engine Reveal - Crystal Islands Experiment"

  test.only "Errors if the URL is not a video":
    assertRaises(Exception, "Invalid YouTube video URL"):
      discard findVideoTitle("https://www.youtube.com/")

