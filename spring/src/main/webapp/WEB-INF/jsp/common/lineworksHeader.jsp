<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<script type="text/javascript">

	// 업무DB 전체 동기화 (권한이 있어야 가능)
	function goSyncWorkDb(type) {
		switch(type) {
		case 'ONE':
			if(confirm('현재 메뉴만 동기화 진행합니다.\n진행하시겠습니까?') == false) {
				return false;
			}
			break;
		case 'ALL':	// 이건 시간이 너무 오래걸려 페이지에서 지원 안함.
			if(confirm('동기화 시간은 최대 1시간 소요됩니다.\n(매일 새벽 1회 자동 진행)\n\n진행하시겠습니까?') == false) {
				return false;
			}
			break;
		}
		
		var param = {
			'sync_type' : type,
			'line_drive_seq' : ${bean.line_drive_seq}
		};
		$M.goNextPageAjax('/workDb/syncLineDrive', $M.toGetParam(param), {method : 'POST', timeout : 60 * 60 * 1000},
			function(result) {
				if(result.success) {
					$M.goNextPage(this_page, 'line_drive_seq=${inputParam.line_drive_seq}', '');
				}
			}
		);
	}
	
	// 자료검색 조회 팝업 연동
	function goWorkDbList(resourceKey) {
		var param = {
			'pop_check_yn' : 'N',
			'redirect_uri' : 'https://drive.worksmobile.com/#/public-group/' + resourceKey
		};
			
		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1280, height=900, left=0, top=0";
		$M.goNextPage('/auth/goPage', $M.toGetParam(param), {popupStatus : poppupOption});
	}
	
	// 자료 검색
	function goSearch() {
		var lineName = $M.getValue("s_line_name");
		if(lineName == "") {
			alert("검색어를 입력해주세요.");
			return false;
		}
		var param = {
				"s_line_name" : lineName
		};

		$M.goNextPageAjax('/workDb/searchLine', $M.toGetParam(param), {method : 'GET'},
			function(result) {
				if(result.success) {
					$M.goNextPage('/workDb/workDb0106', $M.toGetParam(param));
				}
			}
		);
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_line_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	// 뎁스 클릭 / 파일 상위 폴더 클릭 시
	function goDepthPage(lineDriveSeq, pageLevel) {
		var url = "";

		var param = {
				"line_drive_seq" : lineDriveSeq,
				"s_sale_yn" : $M.getValue("s_sale_yn") == "Y" ? "Y" : "",
				"s_sale_dt_yn" : $M.getValue("s_sale_dt_yn") == "Y" ? "Y" : "",
				"s_file_yn" : $M.getValue("s_file_yn") == "Y" ? "Y" : "",
		}
		switch(pageLevel) {
			case "1" : 
				url = "/workDb/workDb0101";
				break;
			case "2" : 
				url = "/workDb/workDb0102";
				break;
			case "3" : 
				url = "/workDb/workDb0103";
				break;
			case "4" : 
				url = "/workDb/workDb0104";
				break;
			case "5" : 
				url = "/workDb/workDb0105";
				break;
		}
		$M.goNextPage(url, $M.toGetParam(param));
		
		if (!e) var e = window.event;
 	    e.cancelBubble = true;
 	    if (e.stopPropagation) e.stopPropagation();
	}
	
	// 체크박스 검색 (판매중, 판매일존재, 파일존재)
	function goSearchCheck(depth) {
		var pageLevel = $M.toNum(depth) > 5 ? 5 : $M.toNum(depth);
		var url = "";

		var param = {
				"s_sale_yn" : $M.getValue("s_sale_yn") == "Y" ? "Y" : "",
				"s_sale_dt_yn" : $M.getValue("s_sale_dt_yn") == "Y" ? "Y" : "",
				"s_file_yn" : $M.getValue("s_file_yn") == "Y" ? "Y" : "",
				"line_drive_seq" : "${inputParam.line_drive_seq}",
		};
		
		switch(pageLevel) {
			case 1 : 
				url = "/workDb/workDb0101";
				break;
			case 2 : 
				url = "/workDb/workDb0102";
				break;
			case 3 : 
				url = "/workDb/workDb0103";
				break;
			case 4 : 
				url = "/workDb/workDb0104";
				break;
			case 5 : 
				url = "/workDb/workDb0105";
				break;
		}
		
		$M.goNextPage(url, $M.toGetParam(param));
	}
	

    // 라인 링크 이동
	function goLineworks(resourceKey) {
		var param = {
			'pop_check_yn' : 'N',
			'redirect_uri' : 'https://drive.worksmobile.com/#/public-group/' + resourceKey
		};
			
		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1280, height=900, left=0, top=0";
		$M.goNextPage('/auth/goPage', $M.toGetParam(param), {popupStatus : poppupOption});
		
		if (!e) var e = window.event;
 	    e.cancelBubble = true;
 	    if (e.stopPropagation) e.stopPropagation();
    }

	// 자료 리스트 폴더 클릭 시
	function goDataListPage(lineDriveSeq) {
		var param = {
				"line_drive_seq" : lineDriveSeq,
				"s_sale_yn" : $M.getValue("s_sale_yn") == "Y" ? "Y" : "",
				"s_sale_dt_yn" : $M.getValue("s_sale_dt_yn") == "Y" ? "Y" : "",
				"s_file_yn" : $M.getValue("s_file_yn") == "Y" ? "Y" : "",
		};
		
		$M.goNextPage('/workDb/workDb0105', $M.toGetParam(param));
	}
	
    // 닫기
    function fnClose() {
        window.close();
    }
    
</script>
<style>
</style>
<!-- 결재선 -->
            <div class="title-wrap">
                <div class="left" style="width:100%;">
                    <h4 class="mr10" style="font-size:13px; font-weight:bold;">${bean.line_name}</h4>
                </div>          
                <div class="btn-group">
                    <div class="right dpf">
						<span style="margin-right:5px;">
							<div class="icon-btn-cancel-wrap">
								<input type="text" class="form-control" id="s_line_name" name="s_line_name" value="${inputParam.s_line_name}">
							</div>
						</span>
                    	<span><button type="button" class="btn btn-info mr10" onclick="javascript:goSearch();">자료 검색</button></span>
                    	<span><button type="button" class="btn btn-info mr10" onclick="javascript:goWorkDbList('${bean.resource_key}');">라인 검색</button></span>
                        <span>전체 ${bean.total}</span>
                        <span class="ver-line">사용 ${bean.used}</span>
                        <span class="ver-line mr10">여유 <strong class="text-primary">${bean.unused}</strong></span>
                    </div>
                </div>
            </div>

            <c:if test="${bean.line_drive_seq ne 0}">
	            <div class="title-wrap">
	                <div class="left" style="width:80%;">
	                    <span class="mr10" style="font-size:12px; font-weight:bold; color: red;">${bean.show_msg }</span>
	                    <span class="mr10" style="color: #ff7f00;">※ Line동기화일시 : ${bean.sync_date}</span>
	                    <c:if test="${SecureUser.line_sync_auth_yn eq 'Y' }">
	                    <span><button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goSyncWorkDb('ONE');">동기화</button></span>
	                    <span><button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goSyncWorkDb('ALL');">전체동기화</button></span></c:if>
	                    <span><button type="button" class="btn btn-danger mr10" onclick="javascript:goWorkDbList('${bean.job_base_key}');">업무기초자료</button>
	                </div>      
	                <div class="right">
						<div class="form-check form-check-inline">
		                   	<span>
								<input class="form-check-input" type="checkbox" id="s_sale_yn" name="s_sale_yn" value="Y" ${inputParam.s_sale_yn eq 'Y' ? 'checked' : '' } onChange="javascript:goSearchCheck('${bean.drive_depth}');">
								<label class="form-check-input" for="s_sale_yn">판매중</label>
							</span>
		                   	<span>
								<input class="form-check-input" type="checkbox" id="s_sale_dt_yn" name="s_sale_dt_yn" value="Y" ${inputParam.s_sale_dt_yn eq 'Y' ? 'checked' : '' } onChange="javascript:goSearchCheck('${bean.drive_depth}');">
								<label class="form-check-input" for="s_sale_dt_yn">판매일존재</label>
							</span>
		                   	<span>
								<input class="form-check-input" type="checkbox" id="s_file_yn" name="s_file_yn" value="Y" ${inputParam.s_file_yn eq 'Y' ? 'checked' : '' } onChange="javascript:goSearchCheck('${bean.drive_depth}');">
								<label class="form-check-input" for="s_file_yn">파일존재</label>
							</span>
						</div>
	                </div>    
	            </div>      
             </c:if>
<!-- 현재경로링크 -->
             <div class="location-wrap">
                <ul class="location-workDb">
                	<c:forEach var="item" items="${pathList}" varStatus="status">
                		<c:set var="className" value=""/>
					    <c:if test="${status.count eq fn:length(pathList)}">
					 		<c:set var="className" value="active"/>
	                    </c:if>
                		<c:choose>
                			<c:when test="${status.index eq 0}">
	                			<li>
			                        <a onclick="javascript:goDepthPage('${item.line_drive_seq}', '1');">
			                            <i class="icon-btn-home"></i>&nbsp;${item.line_name}
			                        </a> 
			                    </li>
                			</c:when>
                			<c:otherwise>
			                    <li>
			                        <a class="${className}" onclick="javascript:goDepthPage('${item.line_drive_seq}', '${item.page_level}');">${item.line_name}</a>
			                    </li>
                			</c:otherwise>
                		</c:choose>
                	</c:forEach>
                </ul>                    
            </div>
<!-- /현재경로링크 -->