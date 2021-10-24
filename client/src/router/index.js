import Vue from "vue";
import VueRouter from "vue-router";
import SelectCharacter from "../views/SelectCharacter.vue";
import Home from "../views/Home.vue";
import store from "../store";
import SelectWeapon from "../views/SelectWeapon.vue";
import Arena from "../views/Arena.vue";

Vue.use(VueRouter);

const routes = [
  {
    path: "/",
    name: "Home",
    component: Home,
  },
  {
    path: "/mint-character",
    name: "Mint",
    component: SelectCharacter
  },
  {
    path: "/mint-weapon",
    name: "MintWeapon",
    component: SelectWeapon
  },
  {
    path: "/arena",
    name: "Arena",
    component: Arena
  }
];

const router = new VueRouter({
  mode: "history",
  base: process.env.BASE_URL,
  routes,
});

router.beforeEach((to, from, next) => {
  console.log(to, from);
  if(to.name !== 'Home' && store.state.currentAddress === null) 
    next({name: "Home"});
  else if(to.name === 'Home' && store.state.currentAddress !== null)
    next({name: "Arena"});
  else if(to.name === 'Arena' && store.state.selectedCharacter === null && store.state.availableCharacters === null)
    next({name: "Mint"})
  else if(to.name === 'Arena' && store.state.selectedCharacter === null && store.state.availableCharacters !== null)
    next({name: "SelectCharacter"})
  else if(to.name === 'MintWeapon' && store.state.selectedCharacter != null && store.state.selectedCharacter.equippedWeapon !== 0)
    next({name: "Arena"})
  else  
    next();
});

export default router;
