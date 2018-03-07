import React, { Component }  from 'react';
import { ActivityIndicator, Animated, Dimensions, FlatList, View, Image, Platform, TouchableHighlight } from 'react-native';
import { List, ListItem, SearchBar, Header } from "react-native-elements";
import { Actions as NavigationActions } from 'react-native-router-flux';
import { StackNavigator } from 'react-navigation';
import moment from 'moment'
import styles from '../components/style/Style'
import theme from '../components/style/Theme'
import VideoScreen from './VideoScreen'
import VideoScreenSearch from './VideoScreenSearch'

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
      console.log(Object.values(data)[0].meta)
      if (Object.values(data)[0].meta === undefined) {
        this.props.navigation.navigate('VideoScreen', { ...data.item });
      } else {
        this.props.navigation.navigate('VideoScreenSearch', { ...data.item })
      }
    };

    render(){
      return (
              <FlatList
                style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
                data={this.state.data}
                renderItem={ ({ item }) => (
                  <View>
                  <ListItem
                    style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
                    button
                    title={item.title} //${item.author}
                    titleNumberOfLines={3}
                    subtitle={`by ${item.author}\n${item.pending_payout_value} • ${moment(item.created).fromNow()}`}
                    subtitleNumberOfLines={2}
                    containerStyle={{ borderBottomWidth: 0, height: ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? 111.25 : 0) : (`${item.meta.video}` !== undefined ? 111.25 : 0)) }}
                    rightTitleStyle={{ textAlignVertical: 'top' }}
                    //  console.log(JSON.stringify(res.results[0].meta.video.info.snaphash)) (JSON.parse(`${item.json_metadata}`).video !== undefined ? (JSON.parse(`${item.json_metadata}`).video.info.snaphash) : "")
                    avatar={{uri: 'https://gateway.ipfs.io/ipfs/' + ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? (JSON.parse(`${item.json_metadata}`).video.info.snaphash) : "") : (`${item.meta.video}` !== undefined ? `${item.meta.video.info.snaphash}` : "")) }}
                    avatarStyle={{ width: 180, height: ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? 101.25 : 0) : (`${item.meta.video}` !== undefined ? 101.25 : 0)), resizeMode : 'cover' }}
                    avatarOverlayContainerStyle={{ width: 180, height: ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? 101.25 : 0) : (`${item.meta.video}` !== undefined ? 101.25 : 0)) }}
                    avatarContainerStyle={{ width: 180, height: ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? 101.25 : 0) : (`${item.meta.video}` !== undefined ? 101.25 : 0)) }}
                    onPress={() => this.handleVideoPress({item})}
                  />
                </View>
                )}
                keyExtractor={item => item.permlink }
                ListHeaderComponent={this.renderHeader}
                ListFooterComponent={this.renderFooter}
                onRefresh={() => this.handleRefresh()}
                refreshing={this.state.refreshing}
                //onEndReached={() => this.handleLoadMore()}
                onEndReachedThreshold={100}
              />
      );
    }
}

export default Home;
