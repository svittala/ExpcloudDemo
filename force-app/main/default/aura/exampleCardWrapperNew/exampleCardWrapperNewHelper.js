({
  generateDataMapped: function () {
    return [
      {
        cardType: "Card with Media",
        cardsPerRow: "3",
        header: "",
        body: "",
        buttonLinkUrl: "https://acf-orr.force.com/identity/idp/login?app=0sp3d000000001s",
        buttonLinkText: "UC Portal",
        mediaUrl: "/resource/1647464641000/SSOImages/sso_images/UCPortal.png",
        mediaAltText: "A placeholder image"
      },
      {
        cardType: "Card with Media",
        cardsPerRow: "3",
        header: "",
        body: "",
        buttonLinkUrl: "https://sso.online.tableau.com/public/idp/SSO",
        buttonLinkText: "Tableau",
        mediaUrl: "/resource/1647464641000/SSOImages/sso_images/tableau.png",
        mediaAltText: "A placeholder image"
      },
      {
        cardType: "Card with Media",
        cardsPerRow: "3",
        header: "",
        body: "",
        buttonLinkUrl: "https://app.slack.com/client/T01S988DX29/C036BLNDUDC",
        buttonLinkText: "Slack",
        mediaUrl: "/resource/1647464641000/SSOImages2/sso_images/quip.png",
        mediaAltText: "A placeholder image"
      },
      {
        cardType: "Card with Media",
        cardsPerRow: "3",
        header: "",
        body: "",
        buttonLinkUrl: "https://app.slack.com/client/T01S988DX29/C036BLNDUDC",
        buttonLinkText: "Slack",
        mediaUrl: "/resource/1647464641000/SSOImages2/sso_images/workday.png",
        mediaAltText: "A placeholder image"
      },
      {
        cardType: "Card with Media",
        cardsPerRow: "3",
        header: "",
        body: "",
        buttonLinkUrl: "https://app.slack.com/client/T01S988DX29/C036BLNDUDC",
        buttonLinkText: "Slack",
        mediaUrl: "/resource/1647464641000/SSOImages2/sso_images/gmail.png",
        mediaAltText: "A placeholder image"
      },
      {
        cardType: "Card with Media",
        cardsPerRow: "3",
        header: "",
        body: "",
        buttonLinkUrl: "https://app.slack.com/client/T01S988DX29/C036BLNDUDC",
        buttonLinkText: "Slack",
        mediaUrl: "/resource/1647464641000/SSOImages2/sso_images/gmeet.svg",
        mediaAltText: "A placeholder image"
      },
      {
        cardType: "Card with Media",
        cardsPerRow: "3",
        header: "",
        body: "",
        buttonLinkUrl: "https://app.slack.com/client/T01S988DX29/C036BLNDUDC",
        buttonLinkText: "Slack",
        mediaUrl: "/resource/1647464641000/SSOImages2/sso_images/gcal.jpg",
        mediaAltText: "A placeholder image"
      }

    ];
  },
  generateDataNotMapped: function () {
    return [

    ];
  },
  generateMap: function () {
    // keys should contain the custom field names
    // values should contain the cardElement key values
    return {
      fieldA: "cardType",
      fieldB: "cardsPerRow",
      fieldC: "header",
      fieldD: "body",
      fieldE: "buttonLinkUrl",
      fieldF: "buttonLinkText",
      fieldG: "mediaUrl",
      fieldH: "mediaAltText"
    };
  },
  generateDataNoCardType: function () {
    return [

    ];
  }
});