<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 > null > 센터 공구 실사 사진등록
-- 작성자 : 박준영
-- 최초 작성일 : 2020-07-21 10:04:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var fileSeq;
	
	// 파일찾기 팝업
	function goSearchFile() {
		var param = {
			upload_type	: 'SERVICE',
			file_type : 'img',
			max_size : 500
		};
		openFileUploadPanel("fnSetImage", $M.toGetParam(param));
	}
	
	// 팝업창에서 받아온 값
	function fnSetImage(result) {
		if (result != null && result.file_seq != null) {
		
			fileSeq = result.file_seq;

			$M.setValue("file_seq",result.file_seq);
			
			// 이미지 그려주기 작업
			$("#image_area").empty();
			$("#image_area").append(
				"<div class='attach-delete'><button type='button' class='btn btn-icon-lg text-light' onclick='javascript:fnRemoveFile()'><i class='material-iconsclose'></i></button></div>"
			   +"<img id='checkToolFileImage' name='checkToolFileImage' src='/file/"+fileSeq+"'  class='icon-profilephoto' tabindex=0  />"
		   	);				
		}
	}
	
	function fnRemoveFile() {
		fileSeq = "";
		
		$M.setValue("file_seq","");
		
		$("#image_area").empty();
		
		$("#image_area").append(
			"<div class='attach-file'><button type='button' class='btn btn-primary-gra' onclick='javascript:goSearchFile();' >파일찾기</button></div>"
		   +"<div class='no-img'><i class='icon-noimg' ></i><div class='no-img-txt' >no images</div></div>"
		);
	}
	
	function goSave() {
		
		var frm = document.main_form;	
		
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if($M.getValue("file_seq") == "") {
			alert("사진을 등록해주세요.")
			return;
		}
		
		
		console.log($M.toValueForm(frm));
		console.log(frm);
		
		$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    		   	opener.setReload();
	    	    	window.close();
				}
			}
		);
		
	}
	
	// 닫기
    function fnClose() {
    	opener.setReload();
    	window.close();
    }
	
	
	</script>
</head>
<body class="bg-white" >
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 사진보기 -->
			<input type="hidden" id="file_seq" 	name="file_seq" value="" >
			<input type="hidden" id="check_dt" 	name="check_dt" value="${inputParam.s_tool_check_dt}" >
			<input type="hidden" id="org_code" 	name="org_code" value="${inputParam.s_center_org_code}" >
			
            <div class="title-wrap">
                <h4>사진보기 : ${inputParam.s_center_org_name}, ${inputParam.s_tool_check_dt}  </h4>
            </div>
            <table class="table-border mt5">
                <colgroup>
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                    <tr>
                        <th class="text-right">구분</th>
                        <td>
                            <select id="svc_tool_box_cd" name="svc_tool_box_cd"  class="form-control width150px">
								<c:forEach items="${centerToolBoxList}" var="item">
									<option value="${item.svc_tool_box_cd}">${item.svc_tool_box_name}</option>
								</c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">사진</th>
                        <td class="photo-upload" id="image_area" >                 
                            <div class="attach-file">
                                <button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile();" >파일찾기</button>
                            </div>
                            <div class="no-img ">
                                <i class="icon-noimg"></i>
                                <div class="no-img-txt">no images</div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>내용</th>
                        <td>
                            <textarea class="form-control" id="remark" name="remark" style="height: 50px;"></textarea>
                        </td>
                    </tr>                    																			
                </tbody>
            </table>
<!-- /사진보기 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>	
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>