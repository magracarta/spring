<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
   <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<body>
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
   <div class="content-wrap">
      <div class="content-box">
   <!-- 메인 타이틀 -->
         <div class="main-title" style="width:900px;">
            <h2>combogrid</h2>
         </div>
   <!-- /메인 타이틀 -->
         <div class="contents">
         	<div>
         		<label>센터</label>
            	<jsp:include page="/WEB-INF/jsp/common/comboGridOrg.jsp">
           		 	<jsp:param name="org_filed_id" value="s_org_center_code"/>
            	</jsp:include>
            	<label> 공통 콤보그리드의 id,value값은 호출하는 페이지에서 jsp:param에 전달 
            	            ( 기본값은 s_org_center_code )
           	 	</label>
			</div>		 	
			<div>
				<label>창고</label>
            	<jsp:include page="/WEB-INF/jsp/common/comboGridWarehouse.jsp">
           		 	<jsp:param name="warehouse_filed_id" value="s_warehouse_code"/>
            	</jsp:include>
         	    <label> 공통 콤보그리드의 id,value값은 호출하는 페이지에서 jsp:param에 전달  
            	              (기본값은 s_warehouse_code )
           	 	</label>
            </div>          	
         </div>
      </div>
   </div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>
