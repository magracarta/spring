<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통팝업 > 업무DB > 업무DB팝업 > null > 업무DB팝업
-- 작성자 : 박예진
-- 최초 작성일 : 2021-03-24 15:20:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
		var listIndex = 1;
		var disListIndex = 1;

        $(document).ready(function () {
			fnInit();
        });

        function fnInit() {
        	// syncYn 버튼에 동기화 권한 추가 필요 
        }
        
     	// 판매중 새폴더 추가
		function fnAddFolder(lineDriveSeq) {
     		var nameArr = $(".add_folder_name");
			var nameYn = nameArr.length == 0 ? true : false;
		
			if(nameYn) {
				var str = ''; 
				str += '<a class="folder-item2 add_folder_name">';
				str += '<div class="thumb">';
				str += '<div class="hover"></div>';
				str += '<span class="icon-folder b-folder"></span>';
				str += '</div>';
				str += '<div class="info">';
				str += '<input type="text" id="resource_name_' + listIndex + '" placeholder="새폴더" onfocusout="javascript:fnChangeName(' + listIndex + ', this.value, \'' + lineDriveSeq + '\', \'change_name\');">';
				str += '</div>';
				str += '</a>';
				$('#addFolder').before(str);
	
				$("#resource_name_" + listIndex).focus();	
				
				listIndex++;
			} else {
				if(confirm("폴더명은 필수입력입니다.")) {
					$(".add_folder_name").remove();
				}
				return false;
			}
		}
     	
     	// 이름 변경 폴더 클릭 시
     	function fnChangeName(idx, name, addSeq, className) {
			if(addSeq != "") {
				if(name == "") {
					alert("폴더명은 필수입력입니다.");
					$(".add_folder_name").remove();
					return false;
				}
				
				goChangeName("resource_name_" + idx, name, addSeq, className);
				return false;
			} else {
	            var removeDiv = document.getElementById(idx);
	            removeDiv.innerHTML = '';

	            var str = ''; 
				str += '<div class="info">';
				str += '<input type="text" id="resource_name_' + idx + '" placeholder="' + name + '" onfocusout="javascript:goChangeName(this.id, \'' + name + '\', \'' + addSeq + '\', \'' + className + '\');">';
				str += '</div>';
				
				$("#"+ idx).append(str);
	           
				$("#resource_name_" + idx).focus();			
				
				if (!e) var e = window.event;
	     	    e.cancelBubble = true;
	     	    if (e.stopPropagation) e.stopPropagation();
				
			}
			
     	}

		// 이름변경
		function goChangeName(inputId, name, addSeq, className) {
			var nameArr = $("." + className);
			var resourceName = $("#" + inputId).val();
			var keyArr = inputId.split('_');
			var lineDriveSeq = keyArr[keyArr.length-1];
			
			if(resourceName == "") {
				resourceName = name;
			}
			
			for(var i = 0; i < nameArr.length; i++) {
				if(nameArr[i].innerText == resourceName) {
					alert("동일한 폴더명이 존재합니다.");
					$("#" + inputId).val(name);
					return false;
				}
			}
			
			// addSeq 유무에 따라 폴더 생성 or 이름 변경
			if(addSeq != "") {
				var param = {
						"line_drive_seq" : addSeq,
						"resource_name" : resourceName
				}
				
				$M.goNextPageAjax(this_page + '/addDriveFolder', $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
				);
			} else {
				var param = {
						"line_drive_seq" : lineDriveSeq,
						"resource_name" : resourceName
				}
				$M.goNextPageAjax(this_page + '/sendRename', $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
				);
			}
		}
		
     	// 폴더 클릭 시 씨리즈 리스트 조회
		function goSeriseListPage(lineDriveSeq) {
			var param = {
					"line_drive_seq" : lineDriveSeq,
					"s_sale_yn" : $M.getValue("s_sale_yn") == "Y" ? "Y" : "",
					"s_sale_dt_yn" : $M.getValue("s_sale_dt_yn") == "Y" ? "Y" : "",
					"s_file_yn" : $M.getValue("s_file_yn") == "Y" ? "Y" : "",
			};
			
			$M.goNextPage('/workDb/workDb0102', $M.toGetParam(param));
		}

        // 닫기
        function fnClose() {
            window.close();
        }

    </script> 
</head>

<body class="bg-white">
<form id="main_form" name="main_form">
 <!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">				
			<jsp:include page="/WEB-INF/jsp/common/lineworksHeader.jsp"></jsp:include>
            <!-- 최신소식 -->
            <div class="title-wrap mt10">            
                <div class="left">
                    <h4>최신소식</h4>
                </div>          
            </div>
            <div class="folder-items2">
				 <c:forEach var="list" items="${recentList}">
				 	<a class="folder-item2">
	                    <div class="date">${list.reg_dt}</div>
	                    <c:if test="${list.file_type eq 'folder'}">
				 			<c:set var="lineDriveSeq" value="${list.line_drive_seq}"/>
				 			<c:set var="resourceKey" value="${list.resource_key}"/>
	                    	<div class="thumb" onclick="javascript:goSeriseListPage('${list.line_drive_seq}');">
	                    </c:if>
	                    <c:if test="${list.file_type ne 'folder'}">
				 			<c:set var="lineDriveSeq" value="${list.up_line_drive_seq}"/>
				 			<c:set var="resourceKey" value="${list.up_resource_key}"/>
	                    	<div class="thumb" onclick="javascript:goLineworks('${list.up_resource_key}');">
	                    </c:if>
	                        <div class="hover"></div>
	                        <div class="btns">
		                    	<c:if test="${list.file_type ne 'folder'}">
		                            <button type="button" class="btn btn-icon btn-light" onclick="javascript:goDepthPage('${list.up_line_drive_seq}', '${list.file_level}');"><i class="material-iconsfolder text-default"></i></button>
		                    	</c:if>
                       			<c:if test="${list.modify_yn eq 'Y'}">
			                        <button type="button" class="btn btn-icon btn-light" onclick="javascript:fnChangeName('${list.line_drive_seq}', '${list.line_name}', '', 'lately_name');"><i class="material-iconscreate text-default"></i></button>
	                            </c:if>
                            	<button type="button" class="btn btn-icon btn-light" onclick="javascript:goLineworks('${resourceKey}');"><i class="material-iconslink text-default"></i></button>
	                        </div>
	                        <span class="icon-folder ${list.file_type}"></span>
	                    </div>
	                    <div class="info lately_name" id="${list.line_drive_seq}">
	                        ${list.line_name}
	                    </div>
	                </a>
				</c:forEach>
            </div>
<!-- /최신소식 -->

            <hr class="div-line">

<!-- 메이커 분류 (판매중) -->
            <div class="title-wrap mt10">            
                <div class="left">
                    <h4>메이커 분류 <span class="text-primary pl10">- 판매중 -</span></h4>
                </div>          
            </div>

            <div class="folder-items2">
				 <c:forEach var="list" items="${makerMap.saley}">
				 	 <a class="folder-item2">
	                    <c:if test="${list.file_type eq 'folder'}">
				 			<c:set var="resourceKey" value="${list.resource_key}"/>
	                    	<div class="thumb" onclick="javascript:goSeriseListPage('${list.line_drive_seq}');"> 
	                    </c:if>
	                    <c:if test="${list.file_type ne 'folder'}">
				 			<c:set var="resourceKey" value="${list.up_resource_key}"/>
	                    	<div class="thumb" onclick="javascript:goLineworks('${list.up_resource_key}');">
	                    </c:if>
                        <div class="hover"></div>
                        <div class="btns">
                       		<c:if test="${list.modify_yn eq 'Y'}">
                            	<button type="button" class="btn btn-icon btn-light" onclick="javascript:fnChangeName('${list.line_drive_seq}', '${list.line_name}', '', 'change_name');"><i class="material-iconscreate text-default"></i></button>
                            </c:if>
                            <button type="button" class="btn btn-icon btn-light" onclick="javascript:goLineworks('${resourceKey}');"><i class="material-iconslink text-default"></i></button>
                        </div>
                        <div class="num">${list.child_folder_count}</div>
                        <span class="icon-folder b-folder"></span>
                    </div>
                    <div class="info change_name" id="${list.line_drive_seq}">
                    	${list.line_name}
                    </div>
                </a>
				</c:forEach>
				<c:if test="${bean.modify_yn eq 'Y'}">
	                <a class="folder-item2" id="addFolder">
	                    <div class="thumb" onclick="javascript:fnAddFolder('${bean.line_drive_seq}');">  <!-- 똑같은 폴더 아이콘 추가하고, 밑에 input 추가하기 -->                     
	                        <span class="icon-folder folder-add"></span>
	                    </div>
	                    <div class="info dpn"> <!-- 폴더 추가 아이콘 클릭시, dpn 클래스 삭제 -->
	                        <input type="text" style="width: 100%;" class="change_name">
	                    </div>
	                </a>
                </c:if>
            </div>
<!-- /메이커 분류 (판매중) -->


            <hr class="div-line">
<!-- 메이커 분류 (판매중지) -->
            <div class="title-wrap mt10">            
                <div class="left">
                    <h4>메이커 분류 <span class="text-default pl10">- 판매중지 -</span></h4>
                </div>          
            </div>

            <div class="folder-items2">
            <c:forEach var="list" items="${makerMap.salen}">
				<a class="folder-item2">
	                    <c:if test="${list.file_type eq 'folder'}">
		 					<c:set var="resourceKey" value="${list.resource_key}"/>
	                    	<div class="thumb" onclick="javascript:goSeriseListPage('${list.line_drive_seq}');">
	                    </c:if>
	                    <c:if test="${list.file_type ne 'folder'}">
		 					<c:set var="resourceKey" value="${list.up_resource_key}"/>
	                    	<div class="thumb" onclick="javascript:goLineworks('${list.up_resource_key}');">
	                    </c:if>
                    <div class="hover"></div>
                    <div class="btns">
                   		<c:if test="${list.modify_yn eq 'Y'}">
                        	<button type="button" class="btn btn-icon btn-light" onclick="javascript:fnChangeName('${list.line_drive_seq}', '${list.line_name}', '', 'dis_change_name');"><i class="material-iconscreate text-default"></i></button>
                        </c:if>
                        <button type="button" class="btn btn-icon btn-light" onclick="javascript:goLineworks('${resourceKey}');"><i class="material-iconslink text-default"></i></button>
                    </div>
                    <div class="num">${list.child_folder_count}</div>
                    <span class="icon-folder g-folder"></span>
             </div>
		            <div class="info dis_change_name" id="${list.line_drive_seq}">
		            	${list.line_name}
		            </div>
                </a>
			</c:forEach>
            </div>
<!-- /메이커 분류 (판매중지) -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>