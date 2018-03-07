import React, { Component }  from 'react';
import { View, Text, FlatList, ScrollView, Dimensions, StatusBar, AsyncStorage, Platform } from 'react-native';
import { Tile, List, ListItem, Divider, Button } from 'react-native-elements';
import theme from '../components/style/Theme'
import { Audio, Video, ScreenOrientation  } from 'expo';
import { Ionicons } from '@expo/vector-icons';
import VideoPlayer from '@expo/videoplayer';
import moment from 'moment'
import Touchable from 'react-native-platform-touchable';

const SYSTEM = Platform.OS === 'ios' ? 'ios' : 'md';

class VideoScreen extends Component {
  static navigationOptions = ({ navigation }) => ({
    header: null,
    tabBarVisible:
      navigation.state.params && navigation.state.params.tabBarHidden
        ? false
        : true,
  });

  constructor(props){
      super(props);
      this.state = {
        loading: false,
        data: [],
        page: 1,
        error: null,
        refreshing: false,
        isPortrait: true,
        username: null,
        encodedToken: null,
      };
    }

    async componentDidMount() {
      const username = await AsyncStorage.getItem('@username:key');
      const encodedToken = await AsyncStorage.getItem('@encodedToken:key');
      if (username && encodedToken !== null){
        this.state = {
          username: username,
          encodedToken: encodedToken,
        };
      }

      this.makeRemoteRequest();
      ScreenOrientation.allow(ScreenOrientation.Orientation.ALL);
      Dimensions.addEventListener(
        'change',
        this.orientationChangeHandler.bind(this)
      );
    }

    makeRemoteRequest = () => {
        const { url } = this.props.navigation.state.params;
        const body = {"id":0,"jsonrpc":"2.0","method":"call","params":["database_api","get_state",[(`${url}`)]]};
        this.setState({ loading: true });

        fetch('https://api.steemit.com', {
            method: 'POST',
            headers: {
              Accept: 'application/json',
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(body),
          })
          .then(res => res.json())
          .then(res => {
            this.setState({
                data: (Object.values(res.result.content)),
                error: res.error || null,
                loading: false,
                refreshing: false,
              });
            })
          .catch(error => {
            this.setState({ error, loading: false, refreshing: false });
          });
      };

  componentWillUnmount() {
    ScreenOrientation.allow(ScreenOrientation.Orientation.PORTRAIT);
    Dimensions.removeEventListener('change', this.orientationChangeHandler);
  }

  orientationChangeHandler(dims) {
    const { width, height } = dims.window;
    const isLandscape = width > height;
    this.setState({ isPortrait: !isLandscape });
    this.props.navigation.setParams({ tabBarHidden: isLandscape });
    ScreenOrientation.allow(ScreenOrientation.Orientation.ALL);
    if (isLandscape) {
      StatusBar.setHidden(true);
    } else {
      StatusBar.setHidden(false);
    }
  }
  switchToLandscape() {
      ScreenOrientation.allow(ScreenOrientation.Orientation.LANDSCAPE);
      StatusBar.setHidden(true);
    }
  switchToPortrait() {
    ScreenOrientation.allow(ScreenOrientation.Orientation.PORTRAIT);
    StatusBar.setHidden(false);
  }

  makeBroadcastRequest(like) {
    console.log(like);
        const { url } = this.props.navigation.state.params;
        var weight = 0;
        if (like) {
          weight = 10000;
        } else {
          weight = -10000;
        };
        const body = {"operations":[["vote",{"voter":"bostrot","author":"bostrot","permlink":`${url}`,"weight":`${weight}`}]]};

        fetch('https://api.steemit.com', {
            method: 'POST',
            headers: {
              Accept: 'application/json',
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(body),
          })
          .then(res => res.json())
          .then(res => {
            this.setState({
                data: (Object.values(res.result.content)),
                error: res.error || null,
              });
            console.log(res);
            })
          .catch(error => {
            this.setState({ error });
          });
    };
  render() {
    const { author, permlink, title, created, json_metadata, pending_payout_value, active_votes } = this.props.navigation.state.params;
    return (
      <ScrollView>
        <VideoPlayer
          videoProps={{
            shouldPlay: true,
            resizeMode: Video.RESIZE_MODE_CONTAIN,
            source: {
              uri: 'https://gateway.ipfs.io/ipfs/' + (JSON.parse(`${json_metadata}`).video !== undefined ? (JSON.parse(`${json_metadata}`).video.content.video480hash) : ""),
            },
          }}

            isPortrait={this.state.isPortrait}
            switchToLandscape={this.switchToLandscape.bind(this)}
            switchToPortrait={this.switchToPortrait.bind(this)}
          playFromPositionMillis={0}
        />
          <ListItem
            hideChevron
            style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
            title={title} //${item.author}
            titleNumberOfLines={3}
            subtitle={`${pending_payout_value}`}
            subtitleNumberOfLines={5}
            containerStyle={{ borderBottomWidth: 0 }}
          />

            <ListItem
              style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
              rightIcon={
                <View style={{flex: 1, flexDirection: 'row'}}>
                  <Touchable
                    background={Touchable.Ripple('#ccc', false)}
                    style={{ marginRight: 30 }}
                    onPress={() => this._makeBroadcastRequest(false)}>
                      <Ionicons
                        name={`${SYSTEM}-thumbs-up`}
                        size={28}
                        color={`${theme.COLOR_GREY}`}
                      />
                  </Touchable>
                    <Touchable
                      background={Touchable.Ripple('#ccc', false)}
                      style={{ marginRight: 5 }}
                      onPress={() => this._makeBroadcastRequest(false)}>
                        <Ionicons
                          name={`${SYSTEM}-thumbs-down`}
                          size={28}
                          color={`${theme.COLOR_GREY}`}
                        />
                    </Touchable>
                </View>
              }
              containerStyle={{ borderBottomWidth: 0 }}
            />

        <Divider />
          <ListItem
            roundAvatar
            style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
            titleNumberOfLines={3}
            subtitle={`${author}\n${moment(created).fromNow()}`}
            subtitleNumberOfLines={5}
            containerStyle={{ borderBottomWidth: 0 }}
            avatar={{uri: `https://img.busy.org/@${author}?width=96&height=96` }}
            rightIcon={
                  <Button title="Subscribe" text="Subscribe" buttonStyle={{backgroundColor: (`${theme.COLOR_ACCENT}`)}} ></Button>
            }
          >
        </ListItem>

          <Divider />

          <ListItem
            style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
            hideChevron
            titleNumberOfLines={3}
            subtitle={(JSON.parse(`${json_metadata}`).video !== undefined ? (JSON.parse(`${json_metadata}`).video.content.description) : "")}
            subtitleNumberOfLines={100}
            containerStyle={{ borderBottomWidth: 0 }}
          />

          <FlatList
            style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
            data={this.state.data}
            renderItem={ ({ item }) => (
              <ListItem
                style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
                roundAvatar
                hideChevron
                avatar={{uri: `https://img.busy.org/@${item.author}?width=96&height=96` }}
                containerStyle={{ borderBottomWidth: 0 }}
                title={(`${item.author}`)}
                subtitleNumberOfLines={100}
                subtitle={(`${item.body}`)}
              />
            )}
            keyExtractor={item => item.title }
          />

      </ScrollView>
    );
  }

}

export default VideoScreen;
