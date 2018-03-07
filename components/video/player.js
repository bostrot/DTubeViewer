import React from 'react';
import { Audio, Video } from 'expo';
import VideoPlayer from '@expo/videoplayer';

export default class Player extends React.Component {
  render() {
    return (
      <VideoPlayer
        videoProps={{
          shouldPlay: true,
          resizeMode: Video.RESIZE_MODE_CONTAIN,
          source: {
            uri: 'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
          },
        }}
        isPortrait={true}
        playFromPositionMillis={0}
      />
    );
  }
}
