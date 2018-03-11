import React, { Component }  from 'react';
import { View, FlatList, Text, ScrollView, Dimensions, StatusBar, AsyncStorage, Platform, Alert, StyleSheet } from 'react-native';
import { ListItem, Divider, Button, Input, Slider } from 'react-native-elements';
import theme from '../components/style/Theme'
import styles from '../components/style/Style'
import { ScreenOrientation, KeepAwake, Video, AdMobBanner } from 'expo';
import { Ionicons } from '@expo/vector-icons';
import VideoPlayer from '@expo/videoplayer';
import moment from 'moment'
import Touchable from 'react-native-platform-touchable';
import HTMLView from 'react-native-htmlview';
import Home from '../navigation/RootNavigation'
import { Analytics, PageHit } from 'expo-analytics';

const SYSTEM = Platform.OS === 'ios' ? 'ios' : 'md';
const SYSTEM0 = Platform.OS === 'ios' ? 'ios' : 'android';

class VideoSearchScreen extends Component {
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
        upColor: `${theme.COLOR_GREY}`,
        downColor: `${theme.COLOR_GREY}`,
        commentText: "",
        sliderValue: 0,
        subscribed: 'Subscribe',
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

      this.setState({
        username,
        encodedToken,
      });

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

  _makeBroadcastRequest = (like) => {
        const { permlink, author } = this.props.navigation.state.params;
        console.log(`user ${this.state.username} ${this.state.encodedToken}`);
        var weight = 0;
        if (like) {
          console.log("like true")
          weight = this.state.sliderValue;
          this.setState({
            upColor: `${theme.COLOR_BLUE}`,
          })
        } else {
          console.log("like false")
          weight = this.state.sliderValue * -1;
          this.setState({
            downColor: `${theme.COLOR_BLUE}`,
          })
        };
        const body = {"operations":[["vote",{"voter":`${this.state.username}`,"author":`${author}`,"permlink":`${permlink}`,"weight":weight}]]};
        console.log("body", body)
        fetch('https://v2.steemconnect.com/api/broadcast', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'authorization': `${this.state.encodedToken}`
            },
            body: JSON.stringify(body),
          })
          .then(res => res.json())
          .then(res => {
            console.log("res... ", res);
            })
          .catch(error => {
        console.log(error);
            this.setState({ error });
          });
    };

    randString() {
      var text = "";
      var possible = "abcdefghijklmnopqrstuvwxyz0123456789";

      for (var i = 0; i < 8; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));

      return text;
    }

    _makeCommentBroadcastRequest = (e) => {
          const { permlink, author } = this.props.navigation.state.params;
          const tempString = this.randString();
          const text = e.nativeEvent.text;
          console.log(text);
          this.setState({
            commentText: '',
          })

          Alert.alert("Success", "Successfully posted comment.")

          const body = {"operations":[["comment",{"parent_author":`${author}`,"parent_permlink":`${permlink}`,"author":`${this.state.username}`,"permlink":`${tempString}`,"title":`${tempString}`,"body":`${text}`,"meta":"{\"app\":\"dtube/0.6\"}"}]]};
          console.log("body", body)
          fetch('https://v2.steemconnect.com/api/broadcast', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'authorization': `${this.state.encodedToken}`
              },
              body: JSON.stringify(body),
            })

            .then(res => res.json())
            .then(res => {

              })
            .catch(error => {
              console.log(error);
              this.setState({ error });
            });
      };

      _subscribeRequest = () => {
            this.setState({
              subscribed: 'Subscribed'
            })
            const { permlink, author } = this.props.navigation.state.params;
            const body = {"operations":[["custom_json",{"required_auths":[],"required_posting_auths":[`${this.state.username}`],"id":"follow","json":"[\"follow\",{\"follower\":\""+`${this.state.username}`+"\",\"following\":\""+`${author}`+"\",\"what\":[\"blog\"]}]"}]]};
            console.log("body", body)
            fetch('https://v2.steemconnect.com/api/broadcast', {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': `${this.state.encodedToken}`
                },
                body: JSON.stringify(body),
              })

              .then(res => res.json())
              .then(res => {

                })
              .catch(error => {
                console.log(error);
                this.setState({ error });
              });
      }

      _makeCommentsBroadcastRequest = (permlink, author, like) => {
            const tempString = this.randString();

            var weight = 0;
            if (like) {
              weight = 10000;
            } else {
              weight = -10000;
            };

            const body = {"operations":[["vote",{"voter":`${this.state.username}`,"author":`${author}`,"permlink":permlink,"weight":weight}]]};
            console.log("body", body)
            fetch('https://v2.steemconnect.com/api/broadcast', {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': `${this.state.encodedToken}`
                },
                body: JSON.stringify(body),
              })

              .then(res => res.json())
              .then(res => {
                })
              .catch(error => {
                console.log(error);
                this.setState({ error });
              });
        };

  render() {
      const analytics = new Analytics('UA-108863569-3');
      analytics.hit(new PageHit('Video Search Screen'), { ua: `${SYSTEM0}` })
        .then(() => console.log("success"))
        .catch(e => console.log(e.message));
    const { author, permlink, title, created, meta, payout, active_votes } = this.props.navigation.state.params;
    return (
      <View>
        <VideoPlayer
          videoProps={{
            shouldPlay: true,
            resizeMode: Video.RESIZE_MODE_CONTAIN,
            source: {
              uri: 'https://gateway.ipfs.io/ipfs/' + (JSON.parse(`${meta}`).video !== undefined ? (JSON.parse(`${meta}`).video.content.videohash) !== undefined ? (JSON.parse(`${meta}`).video.content.videohash) : ((JSON.parse(`${meta}`).video.content.video480hash) !== undefined ? (JSON.parse(`${meta}`).video.content.video480hash) : (JSON.parse(`${meta}`).video.content.video240hash)) : ""),
            },
          }}

            isPortrait={this.state.isPortrait}
            switchToLandscape={this.switchToLandscape.bind(this)}
            switchToPortrait={this.switchToPortrait.bind(this)}
          playFromPositionMillis={0}
        />

      <ScrollView>
        <KeepAwake />
          <ListItem
            hideChevron
            title={title} //${item.author}
            titleNumberOfLines={3}
            subtitle={`${payout}`}
            subtitleNumberOfLines={5}
            containerStyle={{ borderBottomWidth: 0, backgroundColor: (`${theme.BACKGROUND_COLOR}`) }}
          />

            <ListItem
              rightIcon={
                <View style={{flexDirection: 'row'}}>
                <Text>{this.state.sliderValue}</Text>
                  <View style={{ width: 100, marginRight: 20 }}>
                    <Slider
                      step={100}
                      maximumValue={10000}
                      value={this.state.sliderValue}
                      onValueChange={(sliderValue) => this.setState({sliderValue: sliderValue})} />
                  </View>
                  <Touchable
                    background={Touchable.Ripple('#ccc', false)}
                    style={{ marginRight: 30 }}
                    onPress={() => this._makeBroadcastRequest(true)}>
                      <Ionicons
                        name={`${SYSTEM}-thumbs-up`}
                        size={28}
                        color={ `${this.state.upColor}`}
                      />
                  </Touchable>
                    <Touchable
                      background={Touchable.Ripple('#ccc', false)}
                      style={{ marginRight: 5 }}
                      onPress={() => this._makeBroadcastRequest(false)}>
                        <Ionicons
                          name={`${SYSTEM}-thumbs-down`}
                          size={28}
                          color={`${this.state.downColor}`}
                        />
                    </Touchable>
                </View>
              }
              containerStyle={{ borderBottomWidth: 0, backgroundColor: (`${theme.BACKGROUND_COLOR}`) }}
            />
        <Divider />
          <ListItem
            roundAvatar
            titleNumberOfLines={3}
            subtitle={`${author}\n${moment(created).fromNow()}`}
            subtitleNumberOfLines={5}
            containerStyle={{ borderBottomWidth: 0, backgroundColor: (`${theme.BACKGROUND_COLOR}`) }}
            avatar={{uri: `https://img.busy.org/@${author}?width=96&height=96` }}
            rightIcon={
                  <Button text={this.state.subscribed} onPress={() => this._subscribeRequest() } buttonStyle={{backgroundColor: (`${theme.COLOR_ACCENT}`)}} ></Button>
            }
          >
        </ListItem>

        <Divider />
          {
            `${theme.ASUP}` === "true" ?
              <AdMobBanner
                bannerSize="smartBannerPortrait"
                adUnitID={'ca-app-pub-9430927632405311/3217467505'}
                didFailToReceiveAdWithError={this.bannerError}
              /> : null
          }
          <Divider />

          <ListItem
            hideChevron
            titleNumberOfLines={3}
            subtitle={(JSON.parse(`${meta}`).video !== undefined ? (JSON.parse(`${meta}`).video.content.description) : "")}
            subtitleNumberOfLines={100}
            containerStyle={{ borderBottomWidth: 0, backgroundColor: (`${theme.BACKGROUND_COLOR}`) }}
          />


          <Divider />

          <Input
            containerStyle={{ width: "100%", backgroundColor: (`${theme.BACKGROUND_COLOR}`)  }}
            placeholder='Comment something...'
            value={`${this.state.commentText}`}
            onChangeText={(e) => {
              this.setState({
                commentText: e,
              })
            }}
            onSubmitEditing={(text) => this._makeCommentBroadcastRequest(text)}
          />
          <FlatList
            containerStyle={{ height: "100%" }}
            style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
            data={this.state.data}
            renderItem={ ({ item }) => (
              <ListItem
                style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
                roundAvatar
                hideChevron
                avatarContainerStyle={{ height: "100%", backgroundColor: (`${theme.BACKGROUND_COLOR}`) }}
                avatarOverlayContainerStyle={{ flex: 4, justifyContent: "flex-start", backgroundColor: (`${theme.BACKGROUND_COLOR}`) }}
                avatar={{uri: `https://img.busy.org/@${item.author}?width=96&height=96` }}
                titleStyle={{ backgroundColor: `${theme.COLOR_GREY}`, textAlign: 'center', borderRadius: 10, width: ((`${item.author}`).length * 10) }}
                title={(`${item.author}`)}
                subtitleNumberOfLines={100}
                subtitle={
                  <View>
                    <HTMLView
                      value={(`${item.body}`)}
                      style={{ color: (`${theme.COLOR_GREY}`), padding: 10 }}
                    />
                    <View style={{flexDirection: 'row', marginLeft: 10 }}>
                      <Touchable
                        background={Touchable.Ripple('#ccc', false)}
                        style={{ marginRight: 30 }}
                        onPress={() => this._makeCommentsBroadcastRequest(`${item.permlink}`, `${item.author}`, true)}>
                          <Ionicons
                            name={`${SYSTEM}-thumbs-up`}
                            size={20}
                            color={ `${this.state.upColor}`}
                          />
                      </Touchable>
                        <Touchable
                          background={Touchable.Ripple('#ccc', false)}
                          style={{ marginRight: 5 }}
                          onPress={() => this._makeCommentsBroadcastRequest(`${item.permlink}`, `${item.author}`, false)}>
                            <Ionicons
                              name={`${SYSTEM}-thumbs-down`}
                              size={20}
                              color={`${this.state.downColor}`}
                            />
                        </Touchable>
                    </View>
                  </View>}
              />
            )}
            keyExtractor={item => item.title }
          />

      </ScrollView>
      </View>
    );
  }

}

export default VideoSearchScreen;
