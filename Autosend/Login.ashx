<%@ WebHandler Language="C#" Class="Login" %>

using System;
using System.Web;
using System.Data;
using System.Text;
using System.Web.SessionState;

public class Login : IHttpHandler, IRequiresSessionState
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
                _strContent.Append("{\"code\": \"0\", \"msg\": \"禁止访问！\",\"rows\": []}");
            }
            else
            {
                switch (_strAction.Trim().ToLower())
                {
                    case "login": _strContent.Append(UserLogin(context)); break;
                    case "gettext": _strContent.Append("hhhh"); break;
                    default: break;
                }
            }
        }
        context.Response.Write(_strContent.ToString());
    }
    /// <summary>
    /// 用户登录
    /// </summary>
    /// <param name="context"></param>
    /// <returns></returns>
    private string UserLogin(HttpContext context)
    {
        string result = "";
        string _username = context.Request["username"];
        string _password = context.Request["password"];
        if (string.IsNullOrEmpty(_username) || string.IsNullOrEmpty(_password))
            return  "{\"code\": \"0\", \"msg\": \"用户名或密码为空！\"}";
        Model.cmUserInfo model = new Model.cmUserInfo();
        if (context.Session["UserModel"] != null)
        {   //当前浏览器已经有用户登录 判断是不是当前输入的用户
            model = (Model.cmUserInfo)context.Session["UserModel"];
            if (model.username != _username)
            {
                result = "{\"code\": \"0\", \"msg\": \"此浏览器已经有其他用户登录！\"}";
            }
            else
            {
                result = "{\"code\": \"1\", \"msg\": \"登录成功！\"}";
            }
        }
        else
        {
            BLL.cmUserBLL bll = new BLL.cmUserBLL();
            DataTable dt = bll.GetUser(_username.Trim()).Tables[0];
            if (dt.Rows.Count < 0 || dt.Rows.Count > 1)
            {
                result = "{\"code\": \"0\", \"msg\": \"登录错误！\"}";
            }
            else if (dt.Rows.Count == 0)
            {
                result = "{\"code\": \"0\", \"msg\": \"用户名不存在！\"}";
            }
            else if (dt.Rows.Count == 1)
            {
                int _userid = 0;
                int.TryParse(dt.Rows[0]["Id"].ToString(), out _userid);
                model.Id = _userid;
                model.username = dt.Rows[0]["username"].ToString();
                model.password = dt.Rows[0]["password"].ToString();
                if (model.password != _password)
                    result = "{\"code\": \"0\", \"msg\": \"密码错误！\"}";
                else
                {
                    context.Session["UserModel"] = model;
                    result = "{\"code\": \"1\", \"msg\": \"登录成功！\"}";
                }
            }
        }
        return result;
    }

    public bool IsReusable
    {
        get
        {
            return true;
        }
    }

}