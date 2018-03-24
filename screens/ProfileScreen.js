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
            user: [],
        };
      }

      
    componentDidMount() {
        this.makeRemoteRequest();
    }

    makeRemoteRequest = () => {
        console.log("autr");
        const { author } = this.props.navigation.state.params;
        console.log("author", author);
        
        
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
                console.log("user0", res.result);                        
                this.setState({
                    user: res.result,
                    error: res.error || null,
                    loading: false,
                    refreshing: false,
                });
                console.log("user1", this.state.user);
                
            })
            .catch(error => {         
                
                console.log("error", error);       
                this.setState({ error, loading: false, refreshing: false });
        });
    };

    render(){
      const analytics = new Analytics('UA-108863569-3');
      analytics.hit(new PageHit('Profile Screen'), { ua: `${SYSTEM}` })
        .then(() => console.log("success"))
        .catch(e => console.log(e.message));
      
      const { navigate } = this.props.navigation;
      const { author } = this.props.navigation.state.params;
      console.log("cygy", this.state.user);
      
        
      return (
        <View>
            <ImageBackground source={{uri: JSON.parse(this.state.user[0].json_meta).profile.profile_image}}>
                <Image source={{uri: 'https://steemitimages.com/u/'+author+'/avatar/'}}></Image>
            </ImageBackground>
            <VideoList screen="Profile" user={author} nav={navigate} />
        </View>
      );
    }
}

export default ProfileScreen;
