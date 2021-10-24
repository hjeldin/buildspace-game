import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import { ethers } from "ethers";

import "./main.css";
import store from './store';


Vue.use(ethers);
Vue.config.productionTip = false;

new Vue({
  router,
  render: (h) => h(App),
  store: store,
}).$mount("#app");
