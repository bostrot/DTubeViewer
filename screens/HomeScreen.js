import React, { Component }  from 'react';
import { ActivityIndicator, Animated, FlatList, View, ImageBackground, Platform } from 'react-native';
import { ListItem, SearchBar, Header } from "react-native-elements";
import moment from 'moment'
import styles from '../components/style/Style'
import theme from '../components/style/Theme'
import VideoScreen from './VideoScreen'
import { Analytics, PageHit } from 'expo-analytics';

const SYSTEM = Platform.OS === 'ios' ? 'ios' : 'android';

class Home extends Component  {
  scroll = new Animated.Value(0);
  headerY;

  constructor(props){
      super(props);
      this.state = {
        loading: false,
        data: [],
        page: 50,
        error: null,
        refreshing: false,
        value: '',
        showComponent: false,
        videoComponentData: [],
      };
    this.baseState = this.state
    }

    componentDidMount() {
        this.makeRemoteRequest();

    }

    makeRemoteRequest = () => {
        const { page } = this.state;
        const url = `https://api.steemit.com`;
        const body = {"id":"3","jsonrpc":"2.0","method":"call","params":["database_api","get_discussions_by_hot",[{"tag":"dtube","limit":`${page}`,"truncate_body":1}]]};
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
                data: page === 50 ? res.result : [...this.state.data, ...res.result],
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
              //console.log(JSON.stringify(res.results))

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
            page: this.state.page + 50,
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
          page: 50,
          refreshing: true,
        },
        () => {
          this.makeRemoteRequest();
        }
      );
    };

    handleVideoPress(data) {
      console.log("this", data)
      if (Object.values(data)[0].meta === undefined) {
        this.props.navigation.navigate('VideoScreen', { ...data.item });
      } else {
        this.props.navigation.navigate('VideoScreenSearch', { ...data.item })
      }
    };

    render(){
      const analytics = new Analytics('UA-108863569-3');
      analytics.hit(new PageHit('Home Screen'))
        .then(() => console.log("success"))
        .catch(e => console.log(e.message));

      return (
        <View>
              <FlatList
                style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
                data={this.state.data}
                renderItem={ ({ item }) => ((`${item.json_metadata}` !== "undefined" && JSON.parse(`${item.json_metadata}`).video !== undefined) && JSON.parse(`${item.json_metadata}`).video.snaphash !== "undefined") || (`${item.meta}` !== "undefined" && (`${item.meta.video}`) !== undefined && (`${item.meta.video.snaphash}`) !== undefined) ? (
                <View>
                  <ListItem
                    style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
                    button
                    title={item.title} //${item.author}
                    titleNumberOfLines={3}
                    subtitle={`by ${item.author}\n${item.pending_payout_value} • ${moment(item.created).fromNow()}`}
                    subtitleNumberOfLines={2}
                    containerStyle={{ borderBottomWidth: 0, height: 111.25 }}
                    rightTitleStyle={{ textAlignVertical: 'top' }}
                    avatar={
                      <ImageBackground  style={{width: 180, height: 101.25, borderRadius: 5 }}  source={{ uri: ('https://gateway.ipfs.io/ipfs/' + ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? (JSON.parse(`${item.json_metadata}`).video.info.snaphash) : "") : (`${item.meta.video}` !== undefined ? `${item.meta.video.info.snaphash}` : ""))) }}>
                        <ListItem
                          hideChevron
                          title={ (moment.utc(((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? (JSON.parse(`${item.json_metadata}`).video.info.duration) : "") : (`${item.meta.video}` !== undefined ? `${item.meta.video.info.duration}` : "").replace(".",""))*1000).format('HH:mm:ss')) }
                          titleStyle={{ fontSize: 11, color: 'white' }}
                          wrapperStyle={{ marginLeft: 119, marginTop: 70, borderBottomWidth: 0, backgroundColor: 'rgba(52, 52, 52, 0.8)', width: 60, height: 20, padding: 0, borderRadius: 5 }}
                          containerStyle={{ borderBottomWidth: 0 }} />
                      </ImageBackground>
                    }
                    avatarStyle={{ width: 180, height: 101.25 }}
                    avatarOverlayContainerStyle={{ width: 180, height: 101.25 }}
                    avatarContainerStyle={{ width: 180, height: 101.25 }}
                    onPress={() => this.handleVideoPress({item})}
                  />
                </View>
              ): null }
                keyExtractor={item => item.permlink }
                ListHeaderComponent={this.renderHeader}
                ListFooterComponent={this.renderFooter}
                onRefresh={() => this.handleRefresh()}
                refreshing={this.state.refreshing}
                //onEndReached={() => this.handleLoadMore()}
                onEndReachedThreshold={100}
              />
          </View>
      );
    }
}

export default Home;
