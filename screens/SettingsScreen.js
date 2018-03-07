import React from 'react';
import { AppRegistry, AsyncStorage, SectionList, ImageBackground, StyleSheet, Text, View, FlatList, Alert } from 'react-native';
import { Button, ListItem } from 'react-native-elements';
import { WebBrowser, AuthSession } from 'expo';
import { Ionicons } from '@expo/vector-icons';
import Colors from '../constants/Colors';
import theme from '../components/style/Theme';
import jwtDecoder from 'jwt-decode';
import { Actions as NavigationActions } from 'react-native-router-flux';
import moment from 'moment'

// Object to Query String
function toQueryString(params) {
  return '?' + Object.entries(params)
    .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
    .join('&');
}
const auth0Domain = 'https://v2.steemconnect.com/oauth2';

export default class SettingsScreen extends React.Component {

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
      loading: false,
      data: [],
      page: 15,
      error: null,
      refreshing: false,
      value: '',
    });
    this.makeRemoteRequest();
  }

    constructor(props){
      super(props);
      this.state = {
        username: null,
        encodedToken: null,
      };
    }

  _loginWithAuth0 = async () => {
    let redirectUrl = AuthSession.getRedirectUrl();
    const result = await AuthSession.startAsync({
      authUrl: `${auth0Domain}/authorize` + toQueryString({
        client_id: 'dtubeviewer',
        response_type: 'access_token',
        scope: '',
        redirect_uri: "https://auth.expo.io/@bostrot/dtubeviewer",
      }),
    });

    if (result.type === 'success') {
      this.handleParams(result.params);
    }
  }

  _logout = async () => {
    try {
      await AsyncStorage.removeItem('@username:key', null);
    } catch (error) {
      console.error('Could not remove username to local storage.');
    }
    try {
      await AsyncStorage.removeItem('@encodedToken:key', null);
    } catch (error) {
      console.error('Could not remove token to local storage.');
    }
    Alert.alert("Logged out. Please restart the app.")
  }

  handleParams = async  (responseObj) => {
    if (responseObj.error) {
      Alert.alert('Error', responseObj.error_description
        || 'something went wrong while logging in');
      return;
    }
    const encodedToken = responseObj.access_token;
    const decodedToken = jwtDecoder(encodedToken);
    const username = responseObj.username;
    try {
      await AsyncStorage.setItem('@username:key', username);
    } catch (error) {
      console.error('Could not save username to local storage.');
    }
    try {
      await AsyncStorage.setItem('@encodedToken:key', encodedToken);
    } catch (error) {
      console.error('Could not save token to local storage.');
    }
    this.setState({ username, encodedToken });
  }


  makeRemoteRequest = () => {
      const { page } = this.state;
      const url = `https://api.steemit.com`;
      //{"id":8,"jsonrpc":"2.0","method":"call","params":["database_api","get_discussions_by_feed",[{"tag":"bostrot","limit":100,"truncate_body":1}]]}
      //const body = {"id":0,"jsonrpc":"2.0","method":"call","params":["database_api","get_discussions_by_blog",[{"tag":`${this.state.username}`,"limit":100}]]};
      const body = {"id":8,"jsonrpc":"2.0","method":"call","params":["database_api","get_discussions_by_feed",[{"tag":"bostrot","limit":100,"truncate_body":1}]]};
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
              data: res.result,
              error: res.error || null,
              loading: false,
              refreshing: false,
            });
          })
        .catch(error => {
          this.setState({ error, loading: false, refreshing: false });
        });
    };

    handleVideoPress(data) {
      if (Object.values(data)[0].meta === undefined) {
        this.props.navigation.navigate('VideoScreen', { ...data.item });
      } else {
        this.props.navigation.navigate('VideoScreenSearch', { ...data.item })
      }
    };

  render() {
    if (this.state.username !== null ) {
      return (
        <View
          style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}>
        <ListItem
          roundAvatar
          style={{ backgroundColor: (`${theme.BACKGROUND_COLOR}`) }}
          titleStyle={{ color: `${theme.COLOR_PRIMARY_DARK}` }}
          avatarStyle={{ width: 60, height: 60, resizeMode : 'cover' }}
          avatarContainerStyle={{ width: 60, height: 60, backgroundColor: `${Colors.tabIconSelected}`}}
          title={`Logged in as ${this.state.username}`}
          containerStyle={{ borderBottomWidth: 0, height: 80 }}
          avatar={{uri: `https://img.busy.org/@${this.state.username}?width=96&height=96` }} />
        <FlatList
          style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`)}}
          data={this.state.data}
          renderItem={ ({ item }) => (
            <View>
            <ListItem
              style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`), height: ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? 101.25 : 0) : (`${item.meta.video}` !== undefined ? 101.25 : 0)) }}
              button
              title={item.title} //${item.author}
              titleNumberOfLines={3}
              subtitle={`by ${item.author}\n${item.pending_payout_value} • ${moment(item.created).fromNow()}`}
              subtitleNumberOfLines={2}
              containerStyle={{ borderBottomWidth: 0, height: ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? 111.25 : 0) : (`${item.meta.video}` !== undefined ? 111.25 : 0)) }}
              rightTitleStyle={{ textAlignVertical: 'top' }}
              avatar={{uri: 'https://gateway.ipfs.io/ipfs/' + ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? (JSON.parse(`${item.json_metadata}`).video.info.snaphash) : "") : (`${item.meta.video}` !== undefined ? `${item.meta.video.info.snaphash}` : "")) }}
              avatarStyle={{ width: 180, height: ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? 101.25 : 0) : (`${item.meta.video}` !== undefined ? 101.25 : 0)), resizeMode : 'cover' }}
              avatarOverlayContainerStyle={{ width: 180, height: ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? 101.25 : 0) : (`${item.meta.video}` !== undefined ? 101.25 : 0)) }}
              avatarContainerStyle={{ width: 180, height: ((`${item.json_metadata}`) !== "undefined" ? (JSON.parse(`${item.json_metadata}`).video !== undefined ? 101.25 : 0) : (`${item.meta.video}` !== undefined ? 101.25 : 0)) }}
              onPress={() => this.handleVideoPress({item})}
            />
          </View>
          )}
          keyExtractor={item => item.permlink }
        />
      </View>
      )
    }
    return (
      <View
        style={{
          flex: 1,
          alignItems: 'center',
        }}>
        <Button
          onPress={this._loginWithAuth0}
          icon={
            <Ionicons
              name={"md-log-in"}
              size={18}
              color={Colors.tabIconDefault}
            />} buttonStyle={{ width: 200, backgroundColor: (`${theme.COLOR_ACCENT}`)}}  text='Login' />
      </View>
    )
  }

    _handleLogin = () => {
      WebBrowser.openBrowserAsync('https://v2.steemconnect.com/oauth2/authorize?client_id=dtube.app&redirect_uri=https%3A%2F%2Fd.tube%2F%23!%2Fsc2login&scope=');
    };

};
