import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import { ethers } from "ethers";
import VueTailwindModal from "vue-tailwind-modal";

import "./main.css";
import store from './store';

Vue.component("VueTailwindModal",  VueTailwindModal);
Vue.use(ethers);
Vue.config.productionTip = false;

new Vue({
  router,
  render: (h) => h(App),
  store: store,
}).$mount("#app");
