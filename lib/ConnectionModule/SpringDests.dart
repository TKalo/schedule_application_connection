class SpringDests{

  //prefixes
  static final String endPoint = "/websocket-endpoint";
  static final String app = "/app";
  static final String user = "/user";

  //message types
  static final String request = "/request";
  static final String subscribe = "/subscribe";

  //request types
  static final String add = "/add";
  static final String update = "/update";
  static final String delete = "/delete";
  static final String accept = "/accept";
  static final String decline = "/decline";

  //data objects
  static final String workerCreationRequest = "/workerCreationRequest";
  static final String scheduleTemplate = "/scheduleTemplate";
  static final String shiftTemplate = "/shiftTemplate";
  static final String chain ="/chain";
  static final String department ="/department";
  static final String worker ="/worker";
  static final String currentUser = "/currentUser";
  static final String currentStore = "/currentStore";
  static final String schedulePreferences = "/schedulePreferences";

  //subscriptions
  static final String userCreationRequestSub = SpringDests.app + SpringDests.subscribe + SpringDests.workerCreationRequest;
  static final String scheduleTemplateSub = SpringDests.app + SpringDests.subscribe + SpringDests.scheduleTemplate;
  static final String shiftTemplateSub = SpringDests.app + SpringDests.subscribe + SpringDests.shiftTemplate;
  static final String schedulePreferencesSub = SpringDests.app + SpringDests.subscribe + SpringDests.schedulePreferences;


  //destination values
  static final String storeIdValue = "/{storeId}";
  static final String userIdValue = "/{userId}";
}