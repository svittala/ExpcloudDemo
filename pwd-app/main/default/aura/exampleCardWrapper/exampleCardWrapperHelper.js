({
  generateDataMapped: function () {
    return [
      {
        cardType: "Card with Media",
        cardsPerRow: "3",
        header: "",
        body: "",
        buttonLinkUrl: "https://ucportal.acf.hhs.gov/",
        buttonLinkText: "UC Portal",
        mediaUrl: "/resource/1647464641000/SSOImages/sso_images/UCPortal.png",
        mediaAltText: "A placeholder image"
      },
      {
        cardType: "Card",
        cardsPerRow: "3",
        header: "",
        body: "",
        buttonLinkUrl: "https://sso.online.tableau.com/public/idp/SSO",
        buttonLinkText: "Tableau",
        mediaUrl: "/resource/1647464641000/SSOImages/sso_images/tableau.png",
        mediaAltText: "A placeholder image"
      },
      {
        cardType: "Card",
        cardsPerRow: "3",
        header: "",
        body: "Access policy documents via this SSO link",
        buttonLinkUrl: "topiccatalog",
        buttonLinkText: "Topic Catalog",
        mediaUrl: "/resource/1647464641000/SSOImages/sso_images/ACFLogo.png",
        mediaAltText: "A placeholder image"
      },
      {
        cardType: "Card",
        cardsPerRow: "3",
        header: "Slack",
        body: "Access Slack via this SSO link",
        buttonLinkUrl: "https://app.slack.com/client/T01S988DX29/C036BLNDUDC",
        buttonLinkText: "Slack",
        mediaUrl: "/resource/1647464641000/SSOImages/sso_images/slack.png",
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