import { api, LightningElement } from 'lwc';

export default class UacBanner extends LightningElement {
  @api background;
  @api color = "#000000";
  @api fontSize;
  @api fontWeight = "500";
  @api iconName;
  @api iconSize;
  @api iconVariant;
  @api text;

  get backgroundStyle() {
    return (this.background) ? `background: ${this.background};` : '';
  }

  get fontStyle() {
    let style = '';
    if(this.color) {
      style += `color: ${this.color};`;
    }
    if(this.fontSize) {
      style += `font-size: ${this.fontSize};`;
    }
    if(this.fontWeight) {
      style += `font-weight: ${this.fontWeight};`;
    }
    return style;
  }

  get iconObj() {
    let iconObj;
    try{
      if(this.icon) {
        iconObj = JSON.parse(this.icon);
      }
    } catch(error) {
      // eslint-disable-next-line no-console
      console.error(error);
    }
    return iconObj;
  }
}