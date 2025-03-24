<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 > null > 센터 공구 실사 사진관리
-- 작성자 : 박준영
-- 최초 작성일 : 2020-07-21 10:04:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid; 
	var fileSeq;
	
	
	$(document).ready(function() {
		createAUIGrid();
		fnInit();
	});
	
	function createAUIGrid() {
		var gridPros = {
	
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : false,
				enableSorting : true,
				showStateColumn : true
		};
		var columnLayout = [
			{
				dataField : "svc_tool_box_cd",
				visible : false
			},
			{
				dataField : "file_seq",
				visible : false
			},			
			{
				headerText : "구분", 
				dataField : "svc_tool_box_name", 
				style : "aui-center",
				width : "20%"
			},
			{
				headerText : "비고", 
				dataField : "remark", 
				style : "aui-left",
				width : "40%"
			},
			{
				headerText : "등록자", 
				dataField : "reg_mem_name", 
				width : "20%"
			},
			{
				headerText : "등록일", 
				dataField : "reg_date", 
				width : "20%",
				dataType : "date",  
				formatString : "yyyy-mm-dd"
			},
		]
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${toolCheckFileList});
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {

			fileSeq = event.item.file_seq;
			$M.setValue("file_seq",event.item.file_seq);
			$("#checkToolFileImage").attr("src", '/file/'+ event.item.file_seq);
			$("#svc_tool_box_name").html(event.item.svc_tool_box_name);
			$("#remark").html(event.item.remark);
				
		});	
	}
	
	function fnInit() {
		fileSeq = "${toolCheckFile}";
		if (fileSeq == "") {
			fileSeq = "";
		} else {
			$("#image_area").empty();
			$("#image_area").append("<img id='checkToolFileImage' name='checkToolFileImage' src='/file/"+ fileSeq +"' class='icon-profilephoto' tabindex=0  />");			
		}
	}

	// 센터공구실사 사진등록
	function goAdd() {
		

	   	var param = {
	   			s_center_org_code 	: "${inputParam.s_center_org_code}",
	   			s_center_org_name 	: "${inputParam.s_center_org_name}",
	   			s_tool_check_dt 	: "${inputParam.s_tool_check_dt}"
		};
	   		
		var requiredArray = ["s_center_org_code","s_tool_check_dt"];
		var msg = checkPanelParam('setChkToolFileInfo', requiredArray, $M.toGetParam(param));
		
		if(msg != '') {
			alert(msg);
			return;
		}

		$M.goNextPage('/serv/serv0103p07', $M.toGetParam(param), {popupStatus : getPopupProp(550, 450)});
		
	}
	
 	function setReload() {
		location.reload();
    }
	
	// 닫기
    function fnClose() {
    	opener.setReload();
    	window.close();
    }
	

	</script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블1 -->			
            <div class="title-wrap">
                 <h4>사진보기 : ${inputParam.s_center_org_name}, ${ inputParam.s_tool_check_dt }</h4>
        
                 <div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                </div>	
            </div>
       
            <table class="table-border mt5">
                <colgroup>
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
	      			<thead>
	                    <tr>
	                        <th>구분</th>
	                        <th>내용</th>
	                    </tr>
	                </thead>                
                    <tr>
                        <td><span id="svc_tool_box_name" name="svc_tool_box_name" ></span></span></td>                       
                        <td><span id="remark" name="remark" ></span></span></td>
                    </tr>
                    <tr>                
                   	   <td colspan="2" class="photo-upload" id="image_area" >                 
                           <div class="no-img"  >
                               <i class="icon-noimg"></i>
                               <div class="no-img-txt">no images</div>
                           </div>
                       </td>
                    </tr>                    					
                </tbody>
            </table>
<!-- 폼테이블1 -->	         
			<div class="title-wrap mt10">
				<h4>사진목록</h4>
			</div>

            <div id="auiGrid" style="margin-top: 5px; height: 130px;"></div>
            <div class="btn-group mt10">
	     		<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>		
     		</div>
        </div>
    </div>
<!-- /팝업 -->
</body>
</form>
</body>
</html>