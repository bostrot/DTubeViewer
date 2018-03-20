import React, { Component }  from 'react';
import { ActivityIndicator, Animated, FlatList, View, ImageBackground, Image, Platform } from 'react-native';
import { ListItem, SearchBar, Header } from "react-native-elements";
import moment from 'moment'
import styles from '../components/style/Style'
import theme from '../components/style/Theme'
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
            userData: [],
        };
      }

      
    componentDidMount() {        
        console.log("profilescreen");
        
        const { user } = this.props.navigation.state.params;
        this.makeRemoteRequestForUserData(user);
    }

    makeRemoteRequestForUserData = (user) => {
        const { page } = this.state;
        const url = `https://api.steemit.com`;
        var body = {"id":6,"jsonrpc":"2.0","method":"call","params":["database_api","get_accounts",[[user]]]};
        
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

    render(){
      const analytics = new Analytics('UA-108863569-3');
      analytics.hit(new PageHit('Profile Screen'), { ua: `${SYSTEM}` })
        .then(() => console.log("success"))
        .catch(e => console.log(e.message));
      
      const { navigate } = this.props.navigation;
      const { user } = this.props.navigation.state.params;
        
      return (
        <View>
            <ImageBackground source={{uri: JSON.parse(this.state.userData[0].json_metadata).profile.profile_image}}>
                <Image source={{uri: 'https://steemitimages.com/u/'+user+'/avatar/'}}></Image>
            </ImageBackground>
            <VideoList screen="Profile" user={user} nav={navigate} />
        </View>
      );
    }
}

export default ProfileScreen;
