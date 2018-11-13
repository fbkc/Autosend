using Data;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace BLL
{
    public class cmUserBLL
    {
        public DataSet GetUser(string name)
        {
            DataSet ds = SqlHelper.ExecuteDataSet("select * from userInfo where username=" + name);
            return ds;
        }
    }
}