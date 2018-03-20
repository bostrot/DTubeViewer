import React, { Component }  from 'react';
import { ActivityIndicator, Animated, FlatList, View, ImageBackground, Platform, AsyncStorage, Text } from 'react-native';
import { Card, ListItem, SearchBar, Header } from "react-native-elements";
import moment from 'moment'
import styles from '../style/Style'
import theme from '../style/Theme'
import Touchable from 'react-native-platform-touchable';
import VideoScreen from './VideoScreen'
import { Analytics, PageHit } from 'expo-analytics';

const SYSTEM = Platform.OS === 'ios' ? 'ios' : 'android';

class VideoList extends Component  {
  scroll = new Animated.Value(0);
  headerY;

  constructor(props){
      super(props);
      this.state = {
        loading: false,
        data: [],
        page: 12,
        error: null,
        refreshing: false,
        value: '',
        showComponent: false,
        videoComponentData: [],
        username: null,
        encodedToken: null,
        videoData: null,
      };
    this.baseState = this.state
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
          videoData: null,
        });
        this.makeRemoteRequest();
    }

    makeRemoteRequest = () => {
        const { page } = this.state;
        const url = `https://api.steemit.com`;
        var body;
        
        switch (this.props.screen) {
            case "Home":
                body = {"id":"3","jsonrpc":"2.0","method":"call","params":["database_api","get_discussions_by_hot",[{"tag":"dtube","limit":`${page}`,"truncate_body":1}]]};
                break;
            case "Feed":
                body = {"id":"5","jsonrpc":"2.0","method":"call","params":["database_api","get_discussions_by_created",[{"tag":"dtube","limit":`${page}`,"truncate_body":1}]]};
                break;
            case "Settings":
                body = {"id":8,"jsonrpc":"2.0","method":"call","params":["database_api","get_discussions_by_feed",[{"tag":this.state.username,"limit":12,"truncate_body":1}]]};
                break;
        }
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
                data: page === 12 ? res.result : [...this.state.data, ...res.result],
                error: res.error || null,
                loading: false,
                refreshing: false,
              });
            })
          .catch(error => {
            this.setState({ error, loading: false, refreshing: false });
          });
      };

      makeSearchRequest = (search) => {
          const { page } = this.state;
          const url = `https://api.asksteem.com/search?q=meta.video.info.title%3A*%20AND%20${search}&include=meta%2Cpayout`;
          this.setState({ loading: true });

          fetch(url, {
              method: 'GET',
              headers: {
                Accept: 'application/json',
                'Content-Type': 'application/json',
              },
            })
            .then(res => res.json())
            .then(res => {
              this.setState({
                  data: res.results,
                  error: res.error || null,
                  loading: false,
                  refreshing: false,
                });

              })
            .catch(error => {
              this.setState({ error, loading: false, refreshing: false });
            });
        };

    renderHeader = () => {
      return (
        <SearchBar
                lightTheme
                platform={(`${SYSTEM}`)}
                placeholder="Type Here..."
                onChangeText={(e) => this.onChange(e)}/>
            );
    };

    renderFooter = () => {
    if (!this.state.loading) return null;

    return (
      <View
        style={{
          borderTopWidth: 1,
          borderColor: "#CED0CE"
        }}
      >
        <ActivityIndicator animating size="large" />
      </View>
    );
  };

  onChange(e){
    this.setState(this.baseState)
    this.state.data = undefined
    //console.log(this.state.data)
    if (e) {
      this.makeSearchRequest(e);
    } else {
      this.makeRemoteRequest();
    }
  }

    onRefresh() {
      this.setState(this.baseState)
      this.setState({ refreshing: true }, function() {  });
    }

    handleLoadMore() {
      this.setState(this.baseState)
      this.setState(
        {
            page: this.state.page + 12,
        },
        () => {
          this.makeRemoteRequest();
        }
      );
    };

    handleRefresh() {
    this.setState(this.baseState)
      this.setState(
        {
          page: 12,
          refreshing: true,
        },
        () => {
          this.makeRemoteRequest();
        }
      );
    };
    
    render(){
        const vidWidth = 180;
        const vidHeight = 101.25;
      return (
        <View>
              <FlatList
                style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
                data={this.state.data}
                renderItem={ ({ item }) => ((`${item.json_metadata}` !== "undefined" && JSON.parse(`${item.json_metadata}`).video !== undefined) && JSON.parse(`${item.json_metadata}`).video.snaphash !== "undefined") || (`${item.meta}` !== "undefined" && (`${item.meta.video}`) !== undefined && ((`${item.meta.video.snaphash}`) !== undefined && (`${item.meta.video.content.videohash}`) !== undefined)) ? (
                <View>
                        <Card
                            containerStyle={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
                            title={item.title}
                            titleStyle= {{color: (`${theme.COLOR_TEXT}`)}}>
                    <Touchable
                        background={Touchable.Ripple('#ccc', false)}
                        onPress={() => this._handleVideoPress({item})}>
                            <ListItem
                                style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
                                button
                                subtitle={`by ${item.author}\n`+("$"+(`${item.pending_payout_value}` !== "undefined" ? `${item.pending_payout_value}` : `${item.payout}`)).replace(" SBD", "")+`\n${moment(item.created).fromNow()}`}
                                subtitleNumberOfLines={4}
                                containerStyle={{ borderBottomWidth: 0, height: (vidHeight + 10) }}
                                underlayColor={"#F5F5F5"}
                                rightTitleStyle={{ textAlignVertical: 'top' }}
                                avatar={
                                <ImageBackground  style={{width: vidWidth, height:vidHeight}}  source={{ uri: ('https://gateway.ipfs.io/ipfs/' + (item.json_metadata !== undefined ? (JSON.parse(item.json_metadata).video !== undefined ? (JSON.parse(item.json_metadata).video.info.snaphash) : "Qma585tFzjmzKemYHmDZoKMZHo8Ar7YMoDAS66LzrM2Lm1") : (item.meta !== undefined ? item.meta.video.info.snaphash : "Qma585tFzjmzKemYHmDZoKMZHo8Ar7YMoDAS66LzrM2Lm1"))) }}>
                                    <ListItem
                                    hideChevron
                                    title={ (moment.utc(((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? (JSON.parse(`${item.json_metadata}`).video.info.duration) : "") : (`${item.meta.video}` !== undefined ? `${item.meta.video.info.duration}` : "").replace(".",""))*1000).format('HH:mm:ss')) }
                                    titleStyle={{ fontSize: 11, color: 'white' }}
                                    wrapperStyle={{ marginLeft: 119, marginTop: 70, borderBottomWidth: 0, backgroundColor: 'rgba(52, 52, 52, 0.8)', width: 60, height: 20, padding: 0, borderRadius: 5 }}
                                    containerStyle={{ borderBottomWidth: 0 }} />
                                </ImageBackground>
                                }
                                avatarStyle={{ width: vidWidth, height: vidHeight }}
                                avatarOverlayContainerStyle={{ width: vidWidth, height: vidHeight }}
                                avatarContainerStyle={{ width: vidWidth, height: vidHeight }}
                            />
                    </Touchable>
                        </Card>
                </View>
              ): null }
                keyExtractor={item => item.permlink }
                ListHeaderComponent={this.renderHeader}
                ListFooterComponent={this.renderFooter}
                onRefresh={() => this.handleRefresh()}
                refreshing={this.state.refreshing}
                //onEndReached={() => this.handleLoadMore()}
                onEndReachedThreshold={100}
              />{
          (this.state.videoData !== null ? <VideoScreen data={this.state.videoData} screen={this.props.screen} /> : null)}
          </View>
      );
    }
    _handleVideoPress(data) {
      console.log("handleVideo");
      this.setState({
        videoData: null,
        videoData: data.item,
      })
        //this.props.nav('VideoScreen', { ...data.item });
    };

}

export default VideoList;
