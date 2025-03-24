<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통팝업 > 업무DB2 > 업무DB팝업 > null > 업무DB팝업
-- 내   용 : 업무디비의 파일 리스트 옵션 입니다
-- 작성자 : 류성진
-- 최초 작성일 : 2023-02-24
------------------------------------------------------------------------------------------------------------------%>
<script type="text/javascript">

	<%-- 디렉토리 경로들 --%>
	<c:set var="pathseq" value="${fn:split(depth.path_work_db_seq, '/')}" />

	// 파일 업로드
	function fnUpload(work_db_file_seq){
		var params = {
			"work_db_seq" : "${inputParam.work_db_seq}",
		};
		// 파일 수정인 경우 함수 파라메타가 듪어옴
		if ( work_db_file_seq ) params.work_db_file_seq = work_db_file_seq;
		if ( window.parent && window.parent.location.href != window.location.href ){ // 부모창 확인
			window.parent.fnUpload(params);
		}else {
			if ( params . work_db_file_seq)
				$M.goNextPage('/workDb2/workDb0106', $M.toGetParam(params), { popupStatus : getPopupProp(1200, 850) })
			else
				$M.goNextPage('/workDb2/workDb0103', $M.toGetParam(params), { popupStatus : getPopupProp(1200, 850) })
		}
		// 상위 프레임에 전달
	}

	// 새폴더 추가
	function fnAddFolder() {
		if($(".add_folder_name").length == 0) {
			$('#addFolder').before([
				'<a class="folder-item2 add_folder_name">'
				,'<div class="thumb">'
				,'<div class="hover"></div>'
				,'<span class="icon-folder b-folder"></span>'
				,'</div>'
				,'<div class="info">'
				,'<input type="text" class="add_folder_name" id="add_folder_name" maxlength="100" placeholder="새폴더" onfocusout="javascript:fnChangeName(0, this.value, this);">'
				,'</div>'
				,'</a>'
			].join(''))
			$(".add_folder_name").focus();
		} else {
			if(!confirm("폴더명은 필수입력입니다.")) $(".add_folder_name").remove();
			return false;
		}
	}
	// 폴더 수정
	function fnEditFolder(event, idx) {
		event.stopPropagation();
		event.preventDefault();
		var target = $("#folder_item_" + idx + " .info");
		if(target.find("input").length == 0) {
			// data-origin
			target.html('<input type="text" class="add_folder_name" id="add_folder_name" maxlength="100" placeholder="' + target.data("origin") + '" onfocusout="javascript:fnChangeName(' + idx + ', this.value, this);" value="' + target.data("origin") + '">');
			target.find("input").focus();
		} else {
			if(!confirm("폴더명은 필수입력입니다.")) { // 취소
				target.html(target.data("origin"))
			}
		}
	}

	function fnEditFile(event, idx) {
		event.stopPropagation();
		event.preventDefault();
		fnUpload(idx);
	}

	// 폴더 삭제
	function fnDelFolder(event, idx, isAlert) {
		event.stopPropagation();
		event.preventDefault();

		if(isAlert) {
			return alert("폴더내에 파일이 존재합니다.\n삭제를 원하시면 폴더 내  파일을 모두 삭제하시기 바랍니다.");
		}

		if (!confirm("폴더를 삭제 하시겠습니까?")) {
			return false;
		}

		var param = {
			"up_work_db_seq" : "${inputParam.work_db_seq}",
			"work_db_seq" : idx,
			"use_yn" : 'N',
		}
		$M.goNextPageAjax('/workDb2/mkdir', $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
		);
	}
	// 파일삭제
	function fnDelFile(event, idx, updir) {
		event.stopPropagation();
		event.preventDefault();

		if (!confirm("파일을 삭제 하시겠습니까?")) {
			return false;
		}

		$M.goNextPageAjax('/workDb2/delfile/' + updir + '/' + idx, $M.toGetParam({}	), {method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
		);
	}

	// 이름 변경 폴더 클릭 시
	function fnChangeName(idx, name, obj) {
		var param = {
			"up_work_db_seq" : "${inputParam.work_db_seq}",
			"folder_name" : name
		}
		if ( idx ){ // 이름변경
			param.work_db_seq = idx;
			if ( !name && !name.length){
				// 폴더명이 없음
				var target = $("#folder_item_" + idx + " .info");

				if(!confirm("폴더명은 필수입력입니다.")){ // 공란
					target.html(target.data('origin'));
				}else target.find("input").focus();
			}else if ( $(obj).attr('placeholder') == name ) {// 취소
				$("#folder_item_" + idx + " .info").html(name);
			}else {
				// 이름변경
				$M.goNextPageAjax('/workDb2/mkdir', $M.toGetParam(param), {method : 'POST'},
						function(result) {
							if(result.success) {
								location.reload();
							}
						}
				);
			}
		}else { // 신규 생성
			if(!name && !name.length) {
				if(!confirm("폴더명은 필수입력입니다."))
					$(".add_folder_name").remove();
				// return; // 폴더 생성 재개 or 삭제
			}else{
				$M.goNextPageAjax('/workDb2/mkdir', $M.toGetParam(param), {method : 'POST'},
						function(result) {
							if(result.success) {
								location.reload();
							}
						}
				);
			}

			// 신규 생성
		}
	}

	// 페이지 이동
	function goPage(params){
		// 이름 변경중에는 이동불가
		if ($(".add_folder_name").length != 0 ) {
			console.log("파일 수정중! 페이지 이동 실패 - ", $(".add_folder_name").length, $(".info input").length)
			return;
		}
		$M.goNextPage('/workDb2/workDb0102', $M.toGetParam(params), {method : 'GET', dataType : 'html'})
	}

	// 파일 뷰어 팝업
	function goFile(item){

		let viewUrl = item.view_url;
		let needReload = false; // 페이지 새로고침 필요 여부
		let isSuccess = true; // view_url 가져오기 성공 여부
		let param = {
			"work_db_file_seq" : item.seq,
		};

		// 업무DB열람 이력 저장
		$M.goNextPageAjax('/workDb2/add_history', $M.toGetParam(param), {method : 'POST', async: false},
			function(result) {
				if (result.success) {
					// view_url가 존재하지 않을 경우
					if (!viewUrl) {
						param.file_seq = item.file_seq;
						$M.goNextPageAjax('/workDb2/view_url', $M.toGetParam(param), {method : 'POST', async: false},
							function(result) {
								if (result.success) {
									viewUrl = result.view_url;
									needReload = true;
								} else {
									isSuccess = false;
								}
							}
						);
					}
					if (isSuccess) {
						$M.goNextPage(viewUrl, $M.toGetParam([{}]), {popupStatus : getPopupProp(1600, 800)});
						if (needReload) {
							location.reload();
						}
					}
				}
			}
		);
	}

	/**
	 * '최근 열어본 파일' 이력 저장 후 파일다운로드
	 * @param event
	 * @param item file_seq : T_FILE.file_seq, seq : work_db_file_seq
	 */
	function dowloadFile(event, item){
		event.stopPropagation();
		event.preventDefault();

		// 업무DB열람 이력 저장
		let param = {
			"work_db_file_seq" : item.seq,
		};

		$M.goNextPageAjax('/workDb2/add_history', $M.toGetParam(param), {method : 'POST', async: false},
			function(result) {
				if (result.success) {
					// 파일 존재여부 체크 후 있으면 다운로드
					$M.goNextPageAjax("/file/info/" + item.file_seq, '', {method : "GET"},
						function(result) {
							if (result.success) {
								if (result.file_exists_yn == 'Y') {
									$M.goNextPage("/file/" + item.file_seq, $M.toGetParam({}), {method: "GET"});
								} else {
									alert('파일이 없습니다.');
								}
							}
						});
				}
			}
		);
	}

	// 뒤로가기
	function fnCancel(){
		goPage({ // 뒤로가기 - 뎁스가 1인경우
			<c:if test="${fn:length(pathseq) ne 1}" >work_db_seq : '${pathseq[fn:length(pathseq) - 2]}'</c:if>
		});
	}

	// 닫기
	function fnClose() {
		// fnClose
		if ( window.parent && window.parent.location.href != window.location.href ){ // 부모창 확인
			window.parent.fnClose();
			window.close();
		}else window.close();
	}
</script>
<style>
</style>
<%-- 파일 리스트 --%>

<!-- 현재경로링크 -->
<c:choose>
	<c:when test="${(not empty inputParam.work_db_seq and inputParam.work_db_seq ne '0') or (inputParam.work_db_seq eq '0' and isMkdir eq 'false')}">
<div class="location-wrap">
	<ul class="location">
		<li>
			<a href="javascript:goPage({})">
				<i class="icon-btn-home"></i>ERP업무DB
			</a>
		</li>
		<c:forTokens items="${depth.path_root}" delims="/" var="item">
			<li>
				<a href="javascript:goPage({ work_db_seq : '${fn:split(item, '#')[0]}' })" class="active">${fn:split(item, '#')[1]}</a>
			</li>
		</c:forTokens>
		<c:if test="${inputParam.work_db_seq eq '0' and isMkdir eq 'false'}">
			<li>
				<a style="font-weight: bold">검색결과</a>
			</li>
		</c:if>
	</ul>
</div>
	</c:when>
	<c:otherwise>
<div class="title-wrap mt10">
	<div class="left">
		<h4>업무DB 분류</h4>
	</div>
</div>
	</c:otherwise>
</c:choose>
<!-- /현재경로링크 -->
<div class="folder-items2">
	<c:forEach var="item" items="${list}">
		<%-- 파일 리스트를 출력함 --%>
		<c:choose>
			<%-- 폴더 --%>
			<c:when test="${'-1' ne item.dir_cnt}">
				<a id="folder_item_${item.seq}" href="javascript:goPage({ work_db_seq : '${item.seq}' })" class="folder-item2">
					<div class="thumb">
						<div class="hover"></div>
						<div class="btns">
							<c:if test="${SecureUser.mem_no eq item.reg_id or page.fnc.F04409_002 eq 'Y'}">
								<button type="button" class="btn btn-icon btn-light" onclick="fnEditFolder(event, ${item.seq})" title="폴더편집"><i class="material-iconsedit text-default"></i></button>
								<button type="button" class="btn btn-icon btn-light" onclick="fnDelFolder(event, ${item.seq}, ${item.dir_cnt})" title="폴더삭제"><i class="material-iconsclose text-default"></i></button>
							</c:if>
						</div>
						<div class="num">${item.dir_cnt}</div>
						<span class="icon-folder b-folder"></span>
					</div>
					<div class="info" data-origin="${item.name}">${item.name}</div>
				</a>
			</c:when>
			<%-- 폴더 --%>
			<%-- 파일 --%>
			<c:otherwise>
				<a id="file_item_${item.seq}" href="javascript:goFile({seq : '${item.seq}', file_seq : '${item.file_seq}', view_url : '${item.view_url}'})" class="folder-item2">
					<div class="thumb">
						<div class="hover"></div>
						<div class="btns">
							<!-- 다운로드 등록자 or 권한 가능자 -->
							<c:if test="${item.is_download ne '0' or SecureUser.mem_no eq item.reg_id}">
								<button type="button" class="btn btn-icon btn-light" onclick="dowloadFile(event, {file_seq : '${item.file_seq}', seq : '${item.seq}'})" title="파일 다운로드"><i class="material-iconscloud_download text-default"></i></button>
							</c:if>
							<c:if test="${SecureUser.mem_no eq item.reg_id or page.fnc.F04409_001 eq 'Y'}">
								<button type="button" class="btn btn-icon btn-light" onclick="fnEditFile(event, ${item.seq})" title="파일 편집"><i class="material-iconsedit text-default"></i></button>
								<%-- 제거 --%>
								<button type="button" class="btn btn-icon btn-light" onclick="fnDelFile(event, ${item.seq}, ${item.up_work_db_seq})" title="파일 삭제"><i class="material-iconsclose text-default"></i></button>
							</c:if>
						</div>
						<%-- file_ext --%>
						<c:choose>
							<c:when test="${item.file_ext eq 'jpg' or item.file_ext eq 'png' or item.file_ext eq 'jpeg' or item.file_ext eq 'gif' or item.file_ext eq 'tif'}">
								<!-- 이미지 -->
								<span class="icon-folder img"></span>
							</c:when>
							<c:when test="${item.file_ext eq 'avi' or item.file_ext eq 'mpg' or item.file_ext eq 'wmv'}">
								<!-- 비디오 -->
								<span class="icon-folder video"></span>
							</c:when>
							<c:when test="${item.file_ext eq 'zip'}">
								<!-- 압축파일 -->
								<span class="icon-folder zip"></span>
							</c:when>
							<c:when test="${item.file_ext eq 'exe'}">
								<!-- 실행파일 -->
								<span class="icon-folder exe"></span>
							</c:when>
							<c:when test="${item.file_ext eq 'txt'}">
								<!-- 실행파일 -->
								<span class="icon-folder txt"></span>
							</c:when>
							<c:when test="${item.file_ext eq 'doc' or item.file_ext eq 'docx' or item.file_ext eq 'msi' or item.file_ext eq 'pot' or item.file_ext eq 'hwp'}">
								<!-- 문서 -->
								<span class="icon-folder doc"></span>
							</c:when>
							<c:when test="${item.file_ext eq 'pdf'}">
								<!-- PDF 파일 -->
								<span class="icon-folder pdf"></span>
							</c:when>
							<c:when test="${item.file_ext eq 'ppt' or item.file_ext eq 'pptx'}">
								<!-- PPT 파일 -->
								<span class="icon-folder ppt"></span>
							</c:when>
							<c:when test="${item.file_ext eq 'xlsx' or item.file_ext eq 'xls'}">
								<!-- 엑셀 파일 -->
								<span class="icon-folder xlsx"></span>
							</c:when>
						</c:choose>
						<%-- file_ext --%>
					</div>

					<div class="date">
						<fmt:formatDate value="${item.reg_date}" pattern="yyyy-MM-dd" var="date" />
						${date}
					</div>
					<div class="info" data-origin="${item.name}">${item.name}</div>
					<div class="date">${item.tags}</div>
				</a>
			</c:otherwise>
			<%-- 파일 --%>
		</c:choose>
	</c:forEach>
	<%-- 폴더 생성--%>
	<c:if test="${isMkdir ne 'false' and page.fnc.F04409_002 eq 'Y'}">
	<a class="folder-item2" id="addFolder">
		<div class="thumb" onclick="javascript:fnAddFolder('${bean.line_drive_seq}');">
			<span class="icon-folder folder-add"></span>
		</div>
	</a>
	</c:if>
</div>


<!-- /시리즈2 -->
<%-- 파일 리스트 --%>
