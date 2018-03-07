import React from 'react';
import { Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { TabNavigator, TabBarTop } from 'react-navigation';

import Colors from '../constants/Colors';

import HomeScreen from '../screens/HomeScreen';
import LinksScreen from '../screens/LinksScreen';
import SettingsScreen from '../screens/SettingsScreen';
import FeedScreen from '../screens/FeedScreen';

const ICON_PREFIX = Platform.OS === 'ios' ? 'ios' : 'md';

export default TabNavigator(
  {
    Home: {
      screen: HomeScreen,
    },
    Feed: {
      screen: FeedScreen,
    },
    Activity: {
      screen: SettingsScreen,
    },
    Options: {
      screen: LinksScreen,
    },
  },
  {
    navigationOptions: ({ navigation }) => ({
      tabBarIcon: ({ focused }) => {
        const { routeName } = navigation.state;
        let iconName;
          if (routeName === 'Home' && `${ICON_PREFIX}` === 'ios') {
            iconName = `${ICON_PREFIX}-home${focused ? '' : '-outline'}`;
          } else if (routeName === 'Feed' && `${ICON_PREFIX}` === 'ios') {
            iconName = `${ICON_PREFIX}-paper${focused ? '' : '-outline'}`;
          } else if (routeName === 'Activity' && `${ICON_PREFIX}` === 'ios') {
            iconName = `${ICON_PREFIX}-folder${focused ? '' : '-outline'}`;
          } else if (routeName === 'Settings' && `${ICON_PREFIX}` === 'ios') {
            iconName = `${ICON_PREFIX}-options${focused ? '' : '-outline'}`;
          } else if (routeName === 'Home') {
            iconName = `${ICON_PREFIX}-home${focused ? '' : ''}`;
          } else if (routeName === 'Feed') {
            iconName = `${ICON_PREFIX}-paper${focused ? '' : ''}`;
          } else if (routeName === 'Activity') {
            iconName = `${ICON_PREFIX}-folder${focused ? '' : ''}`;
          } else if (routeName === 'Options') {
            iconName = `${ICON_PREFIX}-options${focused ? '' : ''}`;
          }
        return (
          <Ionicons
            name={iconName}
            size={28}
            style={{ marginBottom: -3 }}
            color={focused ? Colors.tabIconSelected : Colors.tabIconDefault}
          />
        );
      },
    }),
    tabBarOptions: {
    activeTintColor: '#DF361A',
    inactiveTintColor: 'gray',
    showLabel: false,
  		style: {
        padding: 4,
  			backgroundColor: 'white',
  			borderTopWidth: 1,
  			borderTopColor: 'white',
  		},
      showIcon: true,
      indicatorStyle: {
          backgroundColor: '#2f95dc',
      },
    },
    tabBarPosition: 'top',
    animationEnabled: true,
    swipeEnabled: true,
  }
);
