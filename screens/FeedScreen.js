import React, { Component }  from 'react';
import { ActivityIndicator, Animated, Dimensions, FlatList, View, ImageBackground, Platform, TouchableHighlight } from 'react-native';
import { List, ListItem, SearchBar, Header } from "react-native-elements";
import { Actions as NavigationActions } from 'react-native-router-flux';
import { StackNavigator } from 'react-navigation';
import moment from 'moment'
import styles from '../components/style/Style'
import theme from '../components/style/Theme'
import VideoScreen from './VideoScreen'
import { Analytics, PageHit } from 'expo-analytics';
import VideoList from '../components/video/VideoList';

const SYSTEM = Platform.OS === 'ios' ? 'ios' : 'android';

class Home extends Component  {

    render(){
      const analytics = new Analytics('UA-108863569-3');
      analytics.hit(new PageHit('New Videos'), { ua: `${SYSTEM}` })
        .then(() => console.log("success"))
        .catch(e => console.log(e.message));
        const { navigate } = this.props.navigation;
      return (
        <VideoList screen="Feed" nav={navigate} />
      );
    }
}

export default Home;
