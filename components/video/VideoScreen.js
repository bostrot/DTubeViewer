import React, { Component }  from 'react';
import { View, FlatList, Text, ScrollView, Dimensions, StatusBar, AsyncStorage, Platform, Alert, StyleSheet, WebView, Animated, LayoutAnimation, PanResponder } from 'react-native';
import { ListItem, Divider, Button, Input, Slider } from 'react-native-elements';
import theme from '../style/Theme'
import { ScreenOrientation, KeepAwake, Video, AdMobBanner, AdMobRewarded } from 'expo';
import { Ionicons } from '@expo/vector-icons';
import VideoPlayer from '@expo/videoplayer';
import moment from 'moment'
import Touchable from 'react-native-platform-touchable';
import HTMLView from 'react-native-htmlview';
import Home from '../../navigation/RootNavigation'
import { Analytics, PageHit } from 'expo-analytics';
import ProfileScreen from '../../screens/ProfileScreen';

import VideoList from './VideoList'

const SYSTEM = Platform.OS === 'ios' ? 'ios' : 'md';
const SYSTEM0 = Platform.OS === 'ios' ? 'ios' : 'android';
const { width: DEVICE_WIDTH, height: DEVICE_HEIGHT } = Dimensions.get('window');


class player extends Component {
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
        feedScreenHeight: 0,    
      };
    }

    async componentDidMount() {
      AdMobRewarded.setAdUnitID('ca-app-pub-9430927632405311/3049946540');
      AdMobRewarded.addEventListener('rewardedVideoDidRewardUser',
        (reward) => {
          console.log('AdMobRewarded => rewarded', reward)
          theme.ASUP = false;
          setTimeout(function() {
            theme.ASUP = true;
          }.bind(this), (
            reward.amount * 60 * 60 * 1000
          ));
        }
      );

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
        const { url } = this.props.data;
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

  componentWillMount() {
    if (this.props.screen === "Settings") {
      this.setState({
        feedScreenHeight: 60,
      })
    }
    this._y = 0;
    this._animation = new Animated.Value(0);
    this._animation.addListener(({ value }) => {
      this._y = value;
    })

    this._panResponder = PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderMove: Animated.event([
        null,
        {
          dy: this._animation,
        },
      ]),
      onPanResponderRelease: (e, gestureState) => {
        if (gestureState.dy > 100) {
          Animated.timing(this._animation, {
            toValue: 300,
            duration: 200,
          }).start();
          this._animation.setOffset(300);
        } else {
          this._animation.setOffset(0);
          Animated.timing(this._animation, {
            toValue: 0,
            duration: 200,
          }).start();
        }
      },
    });
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
        const { permlink, author } = this.props.data;
        console.log(`user ${this.state.username} ${this.state.encodedToken}`);
        var weight = 0;
        if (like) {
          console.log("like true")
          weight = this.state.sliderValue * 100;
          this.setState({
            upColor: `${theme.COLOR_BLUE}`,
          })
        } else {
          console.log("like false")
          weight = this.state.sliderValue * -100;
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
          const { permlink, author } = this.props.data;
          const tempString = this.randString();
          const text = e.nativeEvent.text;
          console.log(text);
          this.setState({
            commentText: '',
          })

          Alert.alert("Success", "Successfully posted comment.")

          const body = {"operations":[["comment",{"parent_author":`${author}`,"parent_permlink":`${permlink}`,"author":`${this.state.username}`,"permlink":`${tempString}`,"title":`${tempString}`,"body":`${text}`,"json_metadata":"{\"app\":\"dtube/0.6\"}"}]]};
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
            const { permlink, author } = this.props.data;
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
    analytics.hit(new PageHit('Video Screen'), { ua: `${SYSTEM0}` })
      .then(() => console.log("success"))
      .catch(e => console.log(e.message));

      
    console.log("data", this.state.videoData);
    

    const videoHeight = DEVICE_WIDTH * (DEVICE_WIDTH / DEVICE_HEIGHT);
    var { author, permlink, title, created, json_metadata, pending_payout_value, active_votes } = this.props.data;
    const { width, height: screenHeight } = Dimensions.get("window");
    const height = width * 0.5625;

    const opacityInterpolate = this._animation.interpolate({
      inputRange: [0, 300],
      outputRange: [1, 0],
    });

    const translateYInterpolate = this._animation.interpolate({
      inputRange: [0, 300],
      outputRange: [0, screenHeight - height - 100 + 40 - this.state.feedScreenHeight],
      extrapolate: "clamp",
    });

    const scaleInterpolate = this._animation.interpolate({
      inputRange: [0, 300],
      outputRange: [1, 0.5],
      extrapolate: "clamp",
    });

    const translateXInterpolate = this._animation.interpolate({
      inputRange: [0, 300],
      outputRange: [0, 85],
      extrapolate: "clamp",
    });

    const scrollStyles = {
      opacity: opacityInterpolate,
      transform: [
        {
          translateY: translateYInterpolate,
        },
      ],
    };

    const videoStyles = {
      transform: [
        {
          translateY: translateYInterpolate,
        },
        {
          translateX: translateXInterpolate,
        },
        {
          scale: scaleInterpolate,
        },
      ],
    };

    if (pending_payout_value === undefined) {
      const { meta, payout } = this.props.data;
      pending_payout_value = payout;
      json_metadata = JSON.stringify(meta);
    }
    return (
        <View style={StyleSheet.absoluteFill} pointerEvents="box-none">
          <Animated.View style={[{ width, height }, videoStyles]}
            {...this._panResponder.panHandlers}>
            <Video
              source={{ uri: 'https://gateway.ipfs.io/ipfs/' + (JSON.parse(`${json_metadata}`).video !== undefined ? (JSON.parse(`${json_metadata}`).video.content.videohash) !== undefined ? (JSON.parse(`${json_metadata}`).video.content.videohash) : ((JSON.parse(`${json_metadata}`).video.content.video480hash) !== undefined ? (JSON.parse(`${json_metadata}`).video.content.video480hash) : (JSON.parse(`${json_metadata}`).video.content.video240hash !== undefined ? JSON.parse(`${json_metadata}`).video.content.video240hash : JSON.parse(`${json_metadata}`).video.content.video720hash)) : "") }}
              rate={1.0}
              volume={1.0}
              isMuted={false}
              resizeMode="contain" 
              shouldPlay
              isLooping
              isPortrait={this.state.isPortrait}
              switchToLandscape={this.switchToLandscape.bind(this)}
              switchToPortrait={this.switchToPortrait.bind(this)}
              playFromPositionMillis={0}
              useNativeControls={true}
              style={[{backgroundColor: "#000"},StyleSheet.absoluteFill]}
            >
            
              <KeepAwake />
            </Video>
          </Animated.View>

          <Animated.ScrollView style={[styles.scrollView, scrollStyles]}>
            <ListItem
              hideChevron
              title={title} //${item.author}
              titleNumberOfLines={3}
              subtitle={("$"+`${pending_payout_value}`).replace(" SBD", "")}
              subtitleNumberOfLines={5}
              containerStyle={{ borderBottomWidth: 0, backgroundColor: (`${theme.BACKGROUND_COLOR}`) }}
            />

              <ListItem
                rightIcon={
                  <View style={{flexDirection: 'row'}}>
                  <Text>{this.state.sliderValue}</Text>
                    <View style={{ width: 100, marginRight: 20 }}>
                      <Slider
                        step={10}
                        maximumValue={100}
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
          <Touchable
            background={Touchable.Ripple('#ccc', false)}>
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
          </Touchable>
          <Divider />
            {
              `${theme.ASUP}` === "true" ?
              <View>
                <AdMobBanner
                  bannerSize="smartBannerPortrait"
                  adUnitID={'ca-app-pub-9430927632405311/3217467505'}
                  didFailToReceiveAdWithError={this.bannerError}
                />
              </View>: null
            }
            
            {
              `${theme.ASUP}` === "true" ?
              <View>
                  <Button 
                    onPress={() => this._handleHideAds()}
                    textStyle={{ color: '#000000', textAlign: "center", fontWeight: 'bold', fontSize: 15 }}
                    buttonStyle={{ width: "100%", backgroundColor: "#fff", height: 50 }}
                    text="Tired of this Ad?"></Button>
              </View>: null
            }
            <Divider />

            <ListItem
              hideChevron
              titleNumberOfLines={3}
              subtitle={(JSON.parse(`${json_metadata}`).video !== undefined ? (JSON.parse(`${json_metadata}`).video.content.description) : "")}
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
                  titleStyle={{ backgroundColor: `${theme.COLOR_GREY}`, textAlign: 'center', borderRadius: 10, color: "white", width: ((`${item.author}`).length * 10) }}
                  title={(`${item.author}`)}
                  subtitleNumberOfLines={100}
                  subtitle={
                    <View>
                      <HTMLView
                        value={(`${item.body}`)}
                        style={{ padding: 10 }}
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

            </Animated.ScrollView>
        </View>
    );
  }
  _handleHideAds = () => {
      AdMobRewarded.requestAd(() => AdMobRewarded.showAd());
  }
  
  _handleAuthorPress() {
    var { author } = this.props.data;    
    this.props.nav("ProfileScreen", {author})
  };

}
    const styles = StyleSheet.create({
      container: {
        flex: 1,
        alignItems: "center",
        justifyContent: "center",
        position: 'absolute',
        top: 0
      },
      scrollView: {
        flex: 1,
        backgroundColor: "#FFF",
      },
    });

export default player;
