import React, { Component }  from 'react';
import { ActivityIndicator, AsyncStorage, Animated, FlatList, View, ImageBackground, Image, Platform, ScrollView, Text, Alert } from 'react-native';
import { ListItem, SearchBar, Header, Button } from "react-native-elements"
import { Util } from 'expo';
import moment from 'moment'
import styles from '../components/style/Style'
import theme from '../components/style/Theme'
import Colors from '../constants/Colors'
import VideoScreen from './VideoScreen'
import { Analytics, PageHit } from 'expo-analytics';
import VideoList from '../components/video/VideoList';

const SYSTEM = Platform.OS === 'ios' ? 'ios' : 'android';

class ProfileScreen extends Component  {
    constructor(props){
        super(props);
        this.state = {
            error: null,
            loading: false,
            refreshing: false,
            user: [],
        };
      }

    componentDidMount() {
        this.makeRemoteRequest();
    }

    makeRemoteRequest = () => {
        const { author } = this.props.navigation.state.params;
        const url = `https://api.steemit.com`;
        var body = {"id":6,"jsonrpc":"2.0","method":"call","params":["base_api","get_accounts",[[author]]]};
        
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
                    user: res.result,
                    error: res.error || null,
                    loading: false,
                    refreshing: false,
                });
            })
            .catch(error => {     
                this.setState({ error, loading: false, refreshing: false });
        });
    };


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
    Util.reload();
    Alert.alert("Logged out. Please restart the app.")
  }

    render(){
      const analytics = new Analytics('UA-108863569-3');
      analytics.hit(new PageHit('Profile Screen'), { ua: `${SYSTEM}` })
        .then(() => console.log("success"))
        .catch(e => console.log(e.message));
      const { navigate } = this.props.navigation;
      const { author } = this.props.navigation.state.params;
      console.log("author", author)
        
      if ((this.state.user).length !== 0) {
        return (
            <View style={{backgroundColor: (`${theme.BACKGROUND_COLOR}`), flex:1}}>
                <ListItem
                    roundAvatar
                    style={{ backgroundColor: (`${theme.BACKGROUND_COLOR}`) }}
                    titleStyle={{ color: `${theme.COLOR_PRIMARY_DARK}` }}
                    avatarStyle={{ width: 60, height: 60, resizeMode : 'cover' }}
                    avatarContainerStyle={{ width: 60, height: 60, backgroundColor: `${Colors.tabIconSelected}`}}
                    title={author}
                    containerStyle={{ borderBottomWidth: 0, height: 80 }}
                    rightIcon={
                        <Button buttonStyle={{ width: 100, height: 40 }} text="Log out"
                        onPress={() => this._logout()}></Button>
                    }
                    avatar={{uri: JSON.parse(this.state.user[0].json_metadata).profile.profile_image }} />
                <VideoList screen="Profile" user={author} nav={navigate} />
            </View>
        );
    }
        return (
            <View>
                <Text>User not found</Text>
            </View>
        )
    }
}

export default ProfileScreen;
