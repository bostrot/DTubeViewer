import React from 'react';
import { SectionList, ScrollView, StyleSheet, Image, Text, View, AsyncStorage, Platform } from 'react-native';
import { WebBrowser, Constants, AdMobRewarded } from 'expo';
import { Ionicons } from '@expo/vector-icons';
import Touchable from 'react-native-platform-touchable';
import { Analytics, PageHit } from 'expo-analytics';

const SYSTEM = Platform.OS === 'ios' ? 'ios' : 'android';

export default class LinksScreen extends React.Component {
  static navigationOptions = {
    title: 'Options',
  };

  constructor(props){
      super(props);
      this.state = {
        username: null,
        encodedToken: null,
      };
    }

  async componentDidMount() {
    AdMobRewarded.addEventListener('rewardedVideoDidRewardUser',
      (reward) => {
        console.log('AdMobRewarded => rewarded', reward)
        theme = {
          ASUP: false
        }
        setTimeout(function() {
        theme = {
          ASUP: true
        }
      }.bind(this), (reward.amount * 60 * 60 * 1000));
      }
    );
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

          { SYSTEM === "android" ? (
            <View>
          <Touchable
            style={styles.option}
            background={Touchable.Ripple('#ccc', false)}
            onPress={this._handleRate}>
            <View style={{ flexDirection: 'row' }}>
              <View style={styles.optionIconContainer}>
                <Ionicons name="md-star" size={22} color="#ccc" />
              </View>
              <View style={styles.optionTextContainer}>
                <Text style={styles.optionText}>Rate on PlayStore</Text>
              </View>
            </View>
          </Touchable>


          <Touchable
            background={Touchable.Ripple('#ccc', false)}
            style={styles.option}
            onPress={this._handlePaypal}>
            <View style={{ flexDirection: 'row' }}>
              <View style={styles.optionIconContainer}>
                <Ionicons name="md-heart" size={22} color="#ccc" />
              </View>
              <View style={styles.optionTextContainer}>
                <Text style={styles.optionText}> Donate via PayPal</Text>
              </View>
            </View>
          </Touchable>

          <Touchable
            background={Touchable.Ripple('#ccc', false)}
            style={styles.option}
            onPress={this._handleBitcoin}>
            <View style={{ paddingLeft: 2, flexDirection: 'row' }}>
              <View style={styles.optionIconContainer}>
                <Ionicons name="logo-bitcoin" size={22} color="#ccc" />
              </View>
              <View style={styles.optionTextContainer}>
                <Text style={styles.optionText}> Donate via Bitcoin</Text>
              </View>
            </View>
          </Touchable>
          </View>
         ): null}

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
        </View>
        <View>
          <Text style={styles.optionsTitleText}>
            Themes
          </Text>
            <Touchable
              background={Touchable.Ripple('#ccc', false)}
              style={styles.option}
              onPress={this._handleBitcoin}>
              <View style={{ paddingLeft: 2, flexDirection: 'row' }}>
                <View style={styles.optionIconContainer}>
                  <Ionicons name="md-color-palette" size={22} color="#ccc" />
                </View>
                <View style={styles.optionTextContainer}>
                  <Text style={styles.optionText}> Coming soon...</Text>
                </View>
              </View>
            </Touchable>
        </View>
      </ScrollView>
    );
  }

    _handleReddit = () => {
      WebBrowser.openBrowserAsync('https://www.reddit.com/r/dtube/comments/7vqxmd/unofficial_android_app/');
    };

    _handleBlog = () => {
      WebBrowser.openBrowserAsync('https://bostrot.pro/index.php/blog/1');
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
      AdMobRewarded.setAdUnitID('ca-app-pub-9430927632405311/3049946540'); // Test ID, Replace with your-admob-unit-id
      AdMobRewarded.setTestDeviceID('EMULATOR');
      AdMobRewarded.requestAd(() => AdMobRewarded.showAd());
    }

    rewardedVideoDidRewardUser


      _handleLike = () => {
      console.log("like false", this.state.username)
        if (this.state.username) {
            var weight = 10000;
            console.log("like true")

            const body = {"operations":[["vote",{"voter":`${this.state.username}`,"author":'bostrot',"permlink":'uc43y5y7',"weight":weight}]]};
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
