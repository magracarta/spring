<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<!--  script  -->
	<script type="text/javascript">
	
		var collectSourceList = []; 
	
		$(document).ready(function() {
			console.log(${list});
			collectSourceList = ${codeMapJsonObj.PERSONAL_COLLECT};
			createAUIGrid();
		});
		
		function fnClose() {
			window.close();
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{ 
					headerText : "변경일", 
					dataField : "reg_date",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "구분", 
					dataField : "seq_no",
					width : "4%",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value == 1){
							return "신규";
						} else {
							return "변경";
						}
					}
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name"
				},
				{ 
					headerText : "담당자", 
					dataField : "reg_id", 
					width : "5%"
				},
				{ 
					headerText : "개인정보수집동의", 
					children: [
						{
							headerText : "동의",
							dataField : "personal_yn",
							width : "4%" 
							
						},
						{ 
							headerText : "확인자", 
							dataField : "personal_mem_name", 
							style : "aui-center",
							width : "5%"
						},
						{ 
							headerText : "날짜", 
							dataField : "personal_dt", 
							dataType : "date",   
							style : "aui-center",
							dataInputString : "yyyymmdd",
							formatString : "yyyy-mm-dd"
						},
						{
							headerText : "수집",
							dataField : "personal_collect_cd",
							labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
								var retStr = "";
								for(var i=0,len=collectSourceList.length; i<len; i++) {
									if(collectSourceList[i]["code_value"] == value) {
										retStr = collectSourceList[i]["code_name"];
										break;
									}
								}
								return retStr;
							}
						}
					]
				},
				{ 
					headerText : "제3자 정보제공동의", 
					children: [
						{
							headerText : "동의",
							dataField : "three_yn",
							width : "4%"
						},
						{ 
							headerText : "확인자", 
							dataField : "three_mem_name", 
							style : "aui-center",
							width : "5%"
						},
						{ 
							headerText : "날짜", 
							dataField : "three_dt", 
							dataType : "date",   
							style : "aui-center",
							dataInputString : "yyyymmdd",
							formatString : "yyyy-mm-dd",
							editable : false
						},
						{
							headerText : "수집",
							dataField : "three_collect_cd",
							labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
								var retStr = "";
								for(var i=0,len=collectSourceList.length; i<len; i++) {
									if(collectSourceList[i]["code_value"] == value) {
										retStr = collectSourceList[i]["code_name"];
										break;
									}
								}
								return retStr;
							}
						}
					]
				},
				{ 
					headerText : "마케팅활용동의", 
					children: [
						{
							headerText : "동의",
							dataField : "marketing_yn",
							width : "4%"
						},
						{ 
							headerText : "확인자", 
							dataField : "marketing_mem_name", 
							style : "aui-center",
							width : "5%",
							editable : false
						},
						{ 
							headerText : "날짜", 
							dataField : "marketing_dt", 
							dataType : "date",   
							style : "aui-center",
							dataInputString : "yyyymmdd",
							formatString : "yyyy-mm-dd",
						},
						{
							headerText : "수집",
							dataField : "marketing_collect_cd",
							labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
								var retStr = "";
								for(var i=0,len=collectSourceList.length; i<len; i++) {
									if(collectSourceList[i]["code_value"] == value) {
										retStr = collectSourceList[i]["code_name"];
										break;
									}
								}
								return retStr;
							}
						}
					]
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#total_cnt").html(${list}.length);
		}
		
	</script>
</head>
<body>
<!-- /script -->
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>개인정보수집내역변경</h2>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">			
            <div class="title-wrap">
                <h4>개인정보수집내역 변경이력</h4>
            </div>			
			<div id="auiGrid" style="margin-top: 5px; height: 310px;"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt5">
                <div class="left">
                    총 <strong class="text-primary" id="total_cnt">0</strong>건
                </div>						
                <div class="right">
                	<button type="button" class="btn btn-info" style="width: 50px;" onclick="javascript:fnClose()">닫기</button>
                    <%-- <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include> --%>
                </div>
            </div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</body>
</html>