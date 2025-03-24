<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통팝업 > 업무DB > 업무DB팝업 > null > 자료 목록
-- 작성자 : 박예진
-- 최초 작성일 : 2021-03-29 11:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
		var listIndex = 1;
	
	    $(document).ready(function () {
	    });
	    
	 	// 새폴더 추가
		function fnAddFolder(lineDriveSeq) {
     		var nameArr = $(".add_folder_name");
			var nameYn = nameArr.length == 0 ? true : false;
		
			if(nameYn) {
				var str = ''; 
				str += '<a class="folder-item2 add_folder_name">';
				str += '<div class="thumb">';
				str += '<div class="hover"></div>';
				str += '<span class="icon-folder y-folder"></span>';
				str += '</div>';
				str += '<div class="info">';
				str += '<input type="text" class="add_folder_name" id="resource_name_' + listIndex + '" placeholder="새폴더" onfocusout="javascript:fnChangeName(' + listIndex + ', this.value, \'' + lineDriveSeq + '\', \'folder_name_' + lineDriveSeq + '\');">';
				str += '</div>';
				str += '</a>';
				$('#addFolder_' + lineDriveSeq).before(str);
		
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
				
				$M.goNextPageAjax('/workDb/workDb0101/addDriveFolder', $M.toGetParam(param), {method : 'POST'},
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
				$M.goNextPageAjax('/workDb/workDb0101/sendRename', $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
				);
			}
		}
	
		// 상위 폴더 클릭 시
		function goDataListPage(lineDriveSeq) {
			var param = {
					"line_drive_seq" : lineDriveSeq,
					"s_sale_yn" : $M.getValue("s_sale_yn") == "Y" ? "Y" : "",
					"s_sale_dt_yn" : $M.getValue("s_sale_dt_yn") == "Y" ? "Y" : "",
					"s_file_yn" : $M.getValue("s_file_yn") == "Y" ? "Y" : ""
			};
			
			$M.goNextPage('/workDb/workDb0104', $M.toGetParam(param));
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
<!-- 시리즈1 폴더는 5레벨로 파일은 링크 -->
			<c:forEach var="subList" items="${subList}">
          	 	<c:if test="${subList.sale_yn eq 'Y'}">
		 			<c:set var="saleYn" value="b-folder"/>
                </c:if>
                <c:if test="${subList.sale_yn ne 'Y'}">
		 			<c:set var="saleYn" value="g-folder"/>
                </c:if>
	            <div class="folder-items2 folder-step">
	                <div class="folder-upper">
	                    <a class="folder-item2">
	                    	<c:if test="${subList.file_type eq 'folder'}">
					 			<c:set var="resourceKey" value="${subList.resource_key}"/>
		                    	<div class="thumb" onclick="javascript:goDataListPage('${subList.line_drive_seq}');">
		                    </c:if>
		                    <c:if test="${subList.file_type ne 'folder'}">
					 		<c:set var="resourceKey" value="${subList.up_resource_key}"/>
		                    	<div class="thumb" onclick="javascript:goLineworks('${subList.up_resource_key}');">
		                    </c:if>
		                        <div class="hover"></div>
		                        <div class="btns">
		                        	<c:if test="${subList.modify_yn eq 'Y'}">
				                        <button type="button" class="btn btn-icon btn-light" onclick="javascript:fnChangeName('${subList.line_drive_seq}', '${subList.line_name}', '', 'folder_high_name');"><i class="material-iconscreate text-default"></i></button>
		                            </c:if>
		                            	<button type="button" class="btn btn-icon btn-light" onclick="javascript:goLineworks('${resourceKey}');"><i class="material-iconslink text-default"></i></button>
		                        </div>
		                        <div class="num">${subList.child_folder_count}</div>
		                        <span class="icon-folder ${saleYn}"></span>
		                    </div>
		                    <div class="info folder_high_name" id="${subList.line_drive_seq}">
		                   		${subList.line_name}
		                    </div>
	                    </a>
	                </div>
	                <div class="folder-lower">
		        		<c:forEach var="subMap" items="${subMap}">
		        			<c:if test="${subMap.key eq subList.line_drive_seq}">
		        				<c:forEach var="item" items="${subMap.value}">
			        				<a class="folder-item2">
					                    <c:if test="${item.file_type eq 'folder'}">
							 			<c:set var="resourceKey" value="${item.resource_key}"/>
				                    		<div class="thumb" onclick="javascript:goDataListPage('${item.line_drive_seq}');">
				                    	</c:if>
					                    <c:if test="${item.file_type ne 'folder'}">
								 		<c:set var="resourceKey" value="${item.up_resource_key}"/>
					                    	<div class="thumb" onclick="javascript:goLineworks('${item.up_resource_key}');">
					                    </c:if>
				                            <div class="hover"></div>
				                            <div class="btns">
				                                <c:if test="${item.modify_yn eq 'Y'}"> 
					                                <button type="button" class="btn btn-icon btn-light" onclick="javascript:fnChangeName('${item.line_drive_seq}', '${item.line_name}', '', 'folder_name');"><i class="material-iconscreate text-default"></i></button>
					                            </c:if>
					                            	<button type="button" class="btn btn-icon btn-light" onclick="javascript:goLineworks('${resourceKey}');"><i class="material-iconslink text-default"></i></button>
				                            </div>
				                            <c:if test="${item.file_type eq 'folder'}"><div class="num">${item.child_folder_count}</div></c:if>
				                            <span class="icon-folder ${item.file_type eq 'folder' ? 'y-folder' : item.file_type}"></span>
				                        </div>
				                        <div class="info folder_name" id="${item.line_drive_seq}">
				                        	${item.line_name}
				                        </div>
				                    </a>
		        				</c:forEach>
		        			</c:if>
		        		</c:forEach>
        				<c:if test="${bean.modify_yn eq 'Y'}">
		                <a class="folder-item2" id="addFolder_${subList.line_drive_seq}">
		                    <div class="thumb" onclick="javascript:fnAddFolder('${subList.line_drive_seq}');">  <!-- 똑같은 폴더 아이콘 추가하고, 밑에 input 추가하기 -->                     
		                        <span class="icon-folder folder-add"></span>
		                    </div>
		                    <div class="info dpn"> <!-- 폴더 추가 아이콘 클릭시, dpn 클래스 삭제 -->
		                        <input type="text" style="width: 100%;" class="folder_name_${subList.line_drive_seq}">
		                    </div>
		                </a>
		                </c:if>
	                </div>           
	            </div>
			</c:forEach>
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