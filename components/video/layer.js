import React, { Component }  from 'react';
import { View, Text, FlatList, ScrollView, Dimensions, StatusBar, AsyncStorage, Platform, Alert, PanResponder, Animated, StyleSheet } from 'react-native';
import { Tile, List, ListItem, Divider, Button, Input } from 'react-native-elements';
import theme from '../style/Theme'
import styles from '../style/Style'
import { Audio, Video, ScreenOrientation, KeepAwake, AdMobBanner } from 'expo';
import { Ionicons } from '@expo/vector-icons';
import VideoPlayer from '@expo/videoplayer';
import moment from 'moment'
import Touchable from 'react-native-platform-touchable';
import HTMLView from 'react-native-htmlview';
import Home from '../../navigation/RootNavigation'
import MainTabNavigator from '../../navigation/MainTabNavigator';
import PropTypes from 'prop-types';

const SYSTEM = Platform.OS === 'ios' ? 'ios' : 'md';

export default class layer extends Component {
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
      };
    }

    componentWillMount() {
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
          weight = 10000;
          this.setState({
            upColor: `${theme.COLOR_BLUE}`,
          })
        } else {
          console.log("like false")
          weight = -10000;
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
              console.log("res... ", res);
              })
            .catch(error => {
          console.log(error);
              this.setState({ error });
            });
      };

      _subscribeRequest = () => {
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
                Alert.alert("Subscribed", "Subscribing successful!");
                console.log("res... ", res);
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
              console.log("like true")
              weight = 10000;
            } else {
              console.log("like false")
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
                console.log("res... ", res);
                })
              .catch(error => {
            console.log(error);
                this.setState({ error });
              });
        };

          handleOpen = () => {
            this._animation.setOffset(0);
            Animated.timing(this._animation, {
              toValue: 0,
              duration: 200,
            }).start();
          }


  static propTypes = {
    value: PropTypes.object,
  }

  render() {
    console.log('layer..', JSON.stringify(this.props.value));
    const { author, permlink, title, created, json_metadata, pending_payout_value, active_votes } = this.props.value;

    const { width, height: screenHeight } = Dimensions.get("window");
    const height = width * 0.5625;

    const opacityInterpolate = this._animation.interpolate({
      inputRange: [0, 300],
      outputRange: [1, 0],
    });

    const translateYInterpolate = this._animation.interpolate({
      inputRange: [0, 300],
      outputRange: [0, screenHeight - height + 40],
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

    return (

            <View style={{zIndex: 1}} >
        <Animated.View
            style={[{ width, height }, videoStyles]}
            {...this._panResponder.panHandlers}
          >
          <VideoPlayer
            videoProps={{
              shouldPlay: true,
              resizeMode: Video.RESIZE_MODE_CONTAIN,
              source: {
                uri: 'https://gateway.ipfs.io/ipfs/' + (JSON.parse(`${json_metadata}`).video !== undefined ? (JSON.parse(`${json_metadata}`).video.content.videohash) !== undefined ? (JSON.parse(`${json_metadata}`).video.content.videohash) : ((JSON.parse(`${json_metadata}`).video.content.video480hash) !== undefined ? (JSON.parse(`${json_metadata}`).video.content.video480hash) : (JSON.parse(`${json_metadata}`).video.content.video240hash)) : ""),
              },
            }}

              isPortrait={this.state.isPortrait}
              switchToLandscape={this.switchToLandscape.bind(this)}
              switchToPortrait={this.switchToPortrait.bind(this)}
            playFromPositionMillis={0}
          />
        </Animated.View>
        <Animated.ScrollView style={[styles.scrollView, scrollStyles]}>
          <KeepAwake />
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
                  <View style={{flexDirection: 'row'}}>
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
                    <Button title="Subscribe" text="Subscribe" onPress={() => this._subscribeRequest() } buttonStyle={{backgroundColor: (`${theme.COLOR_ACCENT}`)}} ></Button>
              }
            >
          </ListItem>

          <Divider />
            {
              `${theme.ASUP}` === true ?
                <AdMobBanner
                  bannerSize="smartBannerPortrait"
                  adUnitID={'ca-app-pub-9430927632405311/3217467505'}
                  didFailToReceiveAdWithError={this.bannerError}
                /> : null
            }
            <Divider />

            <ListItem
              style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
              hideChevron
              titleNumberOfLines={3}
              subtitle={(JSON.parse(`${json_metadata}`).video !== undefined ? (JSON.parse(`${json_metadata}`).video.content.description) : "")}
              subtitleNumberOfLines={100}
              containerStyle={{ borderBottomWidth: 0 }}
            />


            <Divider />

            <View style={{ alignItems: 'center', width: "100%" }}>
            <Input
              containerStyle={{ width: "100%" }}
              placeholder='Comment something...'
              value={`${this.state.commentText}`}
              onChangeText={(e) => {
                this.setState({
                  commentText: e,
                })
              }}
              onSubmitEditing={(text) => this._makeCommentBroadcastRequest(text)}
            />
          </View>

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

        </Animated.ScrollView>
        </View>
    );
  }

}
