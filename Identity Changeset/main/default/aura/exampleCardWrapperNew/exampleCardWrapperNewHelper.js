({
  generateDataMapped: function () {
    return [
      {
        cardType: "Card with Media",
        cardsPerRow: "3",
        header: "",
        body: "UC Portal",
        buttonLinkUrl: "/resource/1649693361000/SSOImages2/sso_images/UCPortal.png",
        buttonLinkText: "UC Portal",
        mediaUrl: "/resource/1647464641000/SSOImages/sso_images/UCPortal.png",
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