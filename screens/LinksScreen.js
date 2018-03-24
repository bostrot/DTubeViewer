import React from 'react';
import { SectionList, ScrollView, StyleSheet, Image, Text, View, AsyncStorage, Platform } from 'react-native';
import { WebBrowser, Constants, AdMobRewarded } from 'expo';
import { Ionicons } from '@expo/vector-icons';
import Touchable from 'react-native-platform-touchable';
import { Analytics, PageHit } from 'expo-analytics';
import theme from '../components/style/Theme'
import navigator from '../navigation/MainTabNavigator'

const SYSTEM = Platform.OS === 'ios' ? 'ios' : 'android';

export default class LinksScreen extends React.Component {
  constructor(props){
      super(props);
      this.state = {
        username: null,
        encodedToken: null,
      };
    }

  async componentDidMount() {

    AdMobRewarded.setAdUnitID('ca-app-pub-9430927632405311/3049946540');
    AdMobRewarded.addEventListener('rewardedVideoDidRewardUser',
      (reward) => {
        console.log('AdMobRewarded => rewarded', reward)
        theme.ASUP = false;
        setTimeout(function() {
          theme.ASUP = true;
        }.bind(this), (
          reward.amount * 60 * 60 * 1000
        ));
      }
    );
    
    AdMobRewarded.requestAd();

    const username = await AsyncStorage.getItem('@username:key');
    const encodedToken = await AsyncStorage.getItem('@encodedToken:key');
    if (username && encodedToken !== null) {
      this.state = {
        username: username,
        encodedToken: encodedToken,
      };
    }

    this.setState({
      username,
      encodedToken,
    });
  }

  render() {
    const analytics = new Analytics('UA-108863569-3');
    analytics.hit(new PageHit('Links Screen'), { ua: `${SYSTEM}` })
      .then(() => console.log("success"))
      .catch(e => console.log(e.message));
    const { manifest } = Constants;
    const sections = [];
    return (
      <ScrollView style={styles.container}>

          <SectionList
            style={styles.container}
            renderItem={this._renderItem}
            stickySectionHeadersEnabled={true}
            keyExtractor={(item, index) => index}
            ListHeaderComponent={ListHeader}
            sections={sections}
          />
        <View>
          <Text style={styles.optionsTitleText}>
            Resources
          </Text>
          <Touchable
            background={Touchable.Ripple('#ccc', false)}
            style={styles.option}
            onPress={this._handleReddit}>
            <View style={{ flexDirection: 'row' }}>
              <View style={styles.optionIconContainer}>
                <Ionicons name="logo-reddit" size={22} color="#ccc" />
              </View>
              <View style={styles.optionTextContainer}>
                <Text style={styles.optionText}>Ask a question on Reddit</Text>
              </View>
            </View>
          </Touchable>

          <Touchable
            background={Touchable.Ripple('#ccc', false)}
            style={styles.option}
            onPress={this._handleBlog}>
            <View style={{ flexDirection: 'row' }}>
              <View style={styles.optionIconContainer}>
                <Ionicons name="md-globe" size={22} color="#ccc" />
              </View>
              <View style={styles.optionTextContainer}>
                <Text style={styles.optionText}> Visit my Blog</Text>
              </View>
            </View>
          </Touchable>
        </View>
        <View>
          <Text style={styles.optionsTitleText}>
            Help
          </Text>
          <Touchable
            background={Touchable.Ripple('#ccc', false)}
            style={styles.option}
            onPress={this._handleLike}>
            <View style={{ flexDirection: 'row' }}>
              <View style={styles.optionIconContainer}>
                <Ionicons name="md-thumbs-up" size={22} color="#ccc" />
              </View>
              <View style={styles.optionTextContainer}>
                <Text style={styles.optionText}> Like</Text>
              </View>
            </View>
          </Touchable>
          
          <Touchable
            background={Touchable.Ripple('#ccc', false)}
            style={styles.option}
            onPress={this._handleHideAds}>
            <View style={{ flexDirection: 'row' }}>
              <View style={styles.optionIconContainer}>
                <Ionicons name="md-color-wand" size={22} color="#ccc" />
              </View>
              <View style={styles.optionTextContainer}>
                <Text style={styles.optionText}> Watch video & hide Ads for 2h</Text>
              </View>
            </View>
          </Touchable>
          
          <Touchable
            background={Touchable.Ripple('#ccc', false)}
            style={styles.option}
            onPress={this._handleSubscribe}>
            <View style={{ flexDirection: 'row' }}>
              <View style={styles.optionIconContainer}>
                <Ionicons name="md-mail" size={22} color="#ccc" />
              </View>
              <View style={styles.optionTextContainer}>
                <Text style={styles.optionText}> Subscribe to Newsletter</Text>
              </View>
            </View>
          </Touchable>
        </View>
        <View>
          <Text style={styles.optionsTitleText}>
            Themes
          </Text>
            <Touchable
              background={Touchable.Ripple('#ccc', false)}
              style={styles.option}
              onPress={this._handleNightMode}>
              <View style={{ paddingLeft: 2, flexDirection: 'row' }}>
                <View style={styles.optionIconContainer}>
                  <Ionicons name="md-color-palette" size={22} color="#ccc" />
                </View>
                <View style={styles.optionTextContainer}>
                  <Text style={styles.optionText}> Night Mode (Experimental - Reload to show)</Text>
                </View>
              </View>
            </Touchable>
        </View>
      </ScrollView>
    );
  }

    _handleReddit = () => {
      WebBrowser.openBrowserAsync('https://www.reddit.com/r/dtube/comments/848rpw/android_and_ios_apps/');
    };

    _handleSubscribe = () => {
      WebBrowser.openBrowserAsync('http://eepurl.com/do_FIr');
    };

    _handleBlog = () => {
      WebBrowser.openBrowserAsync('https://bostrot.pro/index.php/blog/dtube_app');
    };

    _handleRateAppStore = () => {
      WebBrowser.openBrowserAsync('https://itunes.apple.com/us/app/dtube-viewer/id1358140255?l=de&ls=1&mt=8');
    };

    _handleRate = () => {
      WebBrowser.openBrowserAsync('https://play.google.com/store/apps/details?id=pro.bostrot.dtubeviewer');
    };

    _handlePaypal = () => {
      WebBrowser.openBrowserAsync('https://paypal.me/bostrot');
    };

    _handleBitcoin = () => {
      WebBrowser.openBrowserAsync('https://blockchain.info/payment_request?address=1Agf9CArL1QvwLLVrPoB96tmUTS2gCJpf&currency=USD&nosavecurrency=true&message=Donate me a beer');
    };

    _renderSectionHeader = ({ section }) => {
      return <SectionHeader title={section.title} />;
    };

    _handleHideAds = () => {
      AdMobRewarded.isReady(() => AdMobRewarded.showAd());
    }


      _handleLike = () => {
      console.log("like false", this.state.username)
        if (this.state.username) {
            var weight = 10000;
            console.log("like true")

            const body = {"operations":[["vote",{"voter":`${this.state.username}`,"author":'bostrot',"permlink":'772roz4o',"weight":weight}]]};
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
            }
        };

    _renderItem = ({ item }) => {
      if (item.type === 'color') {
        return (
          <SectionContent>
            {item.value && <Color value={item.value} />}
          </SectionContent>
        );
      } else {
        return (
          <SectionContent>
            <Text style={styles.sectionContentText}>
              {item.value}
            </Text>
          </SectionContent>
        );
      }
    };

    _handleNightMode = () => {
      theme.BACKGROUND_COLOR= "#000";
      theme.COLOR_TEXT = "#fff";
    }
}

const ListHeader = () => {
  const { manifest } = Constants;

  return (
    <View style={styles.titleContainer}>
      <View style={styles.titleIconContainer}>
        <AppIconPreview iconUrl={manifest.iconUrl} />
      </View>

      <View style={styles.titleTextContainer}>
        <Text style={styles.nameText} numberOfLines={1}>
          {manifest.name}
        </Text>

        <Text style={styles.slugText} numberOfLines={1}>
          {manifest.slug}
        </Text>

        <Text style={styles.descriptionText}>
          {manifest.description}
        </Text>
      </View>
    </View>
  );
};

const AppIconPreview = ({ iconUrl }) => {
  if (!iconUrl) {
    iconUrl =
      'https://s3.amazonaws.com/exp-brand-assets/ExponentEmptyManifest_192.png';
  }

  return (
    <Image
      source={{ uri: iconUrl }}
      style={{ width: 64, height: 64 }}
      resizeMode="cover"
    />
  );
};

const Color = ({ value }) => {
  if (!value) {
    return <View />;
  } else {
    return (
      <View style={styles.colorContainer}>
        <View style={[styles.colorPreview, { backgroundColor: value }]} />
        <View style={styles.colorTextContainer}>
          <Text style={styles.sectionContentText}>
            {value}
          </Text>
        </View>
      </View>
    );
  }
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  titleContainer: {
    paddingHorizontal: 15,
    paddingTop: 15,
    paddingBottom: 15,
    flexDirection: 'row',
  },
  titleIconContainer: {
    marginRight: 15,
    paddingTop: 2,
  },
  sectionHeaderContainer: {
    backgroundColor: '#fbfbfb',
    paddingVertical: 8,
    paddingHorizontal: 15,
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: '#ededed',
  },
  sectionHeaderText: {
    fontSize: 14,
  },
  sectionContentContainer: {
    paddingTop: 8,
    paddingBottom: 12,
    paddingHorizontal: 15,
  },
  sectionContentText: {
    color: '#808080',
    fontSize: 14,
  },
  nameText: {
    fontWeight: '600',
    fontSize: 18,
  },
  slugText: {
    color: '#a39f9f',
    fontSize: 14,
    backgroundColor: 'transparent',
  },
  descriptionText: {
    fontSize: 14,
    marginTop: 6,
    color: '#4d4d4d',
  },
  colorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  colorPreview: {
    width: 17,
    height: 17,
    borderRadius: 2,
    marginRight: 6,
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: '#ccc',
  },
  colorTextContainer: {
    flex: 1,
  },
  optionsTitleText: {
    fontSize: 16,
    marginLeft: 15,
    marginTop: 9,
    marginBottom: 12,
  },
  optionIconContainer: {
    marginRight: 9,
  },
  option: {
    backgroundColor: '#fdfdfd',
    paddingHorizontal: 15,
    paddingVertical: 15,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#EDEDED',
  },
  optionText: {
    fontSize: 15,
    marginTop: 1,
  },
});
