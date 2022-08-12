({
  generateDataMapped: function () {
    return [
      {
        cardType: "Card with Media",
        cardsPerRow: "3",
        header: "",
        body: "UC Portal",
        buttonLinkUrl: "https://ssoit-acf-orr.cs234.force.com/identity/idp/login?app=0sp3d000000001s",
        buttonLinkText: "UC Portal",
        mediaUrl: "/identity/resource/1649693361000/SSOImages2/sso_images/UCPortal.png",
        mediaAltText: "UC Portal Image"
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