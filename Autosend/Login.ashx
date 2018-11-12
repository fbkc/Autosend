<%@ WebHandler Language="C#" Class="Login" %>

using System;
using System.Web;
using System.Data;
using System.Text;

public class Login : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/html";
        StringBuilder _strContent = new StringBuilder();
        if (_strContent.Length == 0)
        {
            string _strAction = context.Request.Params["action"];
            if (string.IsNullOrEmpty(_strAction))
            {
                _strContent.Append("{\"msg\": \"0\", \"msgbox\": \"禁止访问！\",\"rows\": []}");
            }
            else
            {
                switch (_strAction.Trim().ToLower())
                {
                    case "userlogin": _strContent.Append(UserLogin(context)); break;
                    default: break;
                }
            }
        }
        context.Response.Write(_strContent.ToString());
    }

    private string UserLogin(HttpContext context)
    {
        string result = "";
        string _username = context.Request.Form["username"];
        string _password = context.Request.Form["password"];
        Model.cmUser model = new Model.cmUser();
        if (context.Session["UserModel"] != null)
        {   //当前浏览器已经有用户登录 判断是不是当前输入的用户
            model = (Model.cmUser)context.Session["UserModel"];
            if (model.username != _username)
            {
                result = "{\"msg\": \"0\", \"msgbox\": \"此浏览器已经有其他用户登录！\"}";
            }
            else
            {
                result = "{\"msg\": \"1\", \"msgbox\": \"登录成功！\"}";
            }
        }
        else
        {
            BLL.cmUserBLL bll = new BLL.cmUserBLL();
            string strWhere = string.Format("username='{0}'", _username);// and [Password]='{1}', _password
            DataTable dt = bll.GetUser(strWhere).Tables[0];
            if (dt.Rows.Count < 0 || dt.Rows.Count > 1)
            {
                result = "{\"msg\": \"0\", \"msgbox\": \"登录错误！\"}";
            }
            if (dt.Rows.Count == 0)
            {
                result = "{\"msg\": \"0\", \"msgbox\": \"用户名不存在！\"}";
            }
            if (dt.Rows.Count == 1)
            {
                int _userid = 0;
                int.TryParse(dt.Rows[0]["Id"].ToString(), out _userid);
                model.Id = _userid;
                model.username = dt.Rows[0]["username"].ToString();
                context.Session["UserModel"] = model;
                result = "{\"msg\": \"1\", \"msgbox\": \"登录成功！\"}";
            }
            else
            {
                result = "{\"msg\": \"0\", \"msgbox\": \"用户名或密码错误！\"}"; 
            }
        }
        return result;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}