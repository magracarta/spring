<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
		});
		// 받아온 값 세팅할 name 구하는데 사용
		var nameStr 	= "apprName";
		var memNoStr 	= "apprNum";
		var setApprName = "";
		var setApprMemNo = "";
		
		// 직원조회 팝업 호출 결재선에서 사용
		function fnPopMemName(seqNum) {
			setName 	= nameStr.concat(seqNum);
			setMemNo 	= memNoStr.concat(seqNum);
			openSearchMemberPanel('fnSetMemName');
		}
		
		// 직원조회 결과 데이터 받아서 해당 inputbox에 세팅 
		function fnSetMemName(result) {
			var frm = document.main_form;
			console.log("변경 - 이름 : " + result.mem_name + " / 회원번호 : " + result.mem_no);
			$M.setValue(frm, setName, result.mem_name);
			$M.setValue(frm, setMemNo, result.mem_no);
		}
		
		// 직원조회 결과 데이터 받아서 해당 inputbox있는 값 초기화
		function fnMemNameDel(seqNum) {
			var frm = document.main_form;
			var nameDel 	= nameStr.concat(seqNum);
			var memNoDel 	= memNoStr.concat(seqNum);
			console.log("삭제 - nameSeq : " + nameDel + " / memNoSeq : " + memNoDel);
			$M.setValue(frm, nameDel, "");
			$M.setValue(frm, memNoDel, "");
		}
		
		// 등록고객 검색 팝업
		function goSearch() {
			var param = {
				s_appr_job_cd : $M.getValue("s_appr_job_cd")
			}

			$M.goNextPage(this_page, $M.toGetParam(param), {method:"GET"});
		}
		
		// 저장
		function goSave(type) {
			var frm = document.main_form;
			var apprMemStr = [];	// 세팅된 mem_no
			var checkVal = "";		// 중복체크 할 mem_no 값
			var checkResult = true;	// 중복값 있으면 false로 변경
			// class이름을 통해 mon_no 가져옴
			$(".checkMemNo").each(function(i) {
				checkVal = $M.getValue($(this).attr("id"));
				if(checkVal != "") {
					console.log("apprMemStr : " + apprMemStr + " / checkVal : " + checkVal);
					if($.inArray(checkVal, apprMemStr) != -1) {
						alert("결재선 이름 중복 다시등록해주세요");
						checkResult = false;
					} else {
						apprMemStr.push(checkVal);
					};
				}
			});
			var p_appr_job_cd = '${apprBean.appr_job_cd}';
			alert(apprMemStr + '# appr_job_cd=' + p_appr_job_cd);
			// 중복있거나 job_cd값이 없으면 return
			if(checkResult == false || p_appr_job_cd == "") {
				return;
			}
	
			var param = {
				appr_job_cd : p_appr_job_cd,
				appr_mem_no_str : $M.getArrStr(apprMemStr),
				last_mem_appr_seq : ${apprBean.mem_appr_seq}
			}
			
			$M.goNextPageAjaxSave("/smpl/smpl0103/${apprBean.last_mem_appr_seq}/" + type, $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						alert("최종결재라인번호 : " + result.last_mem_appr_seq);
						$M.goNextPage("/smpl/smpl0103/" + result.last_mem_appr_seq);
					};
				}
			);
		}
		
		function fnResultApproval(result) {
			var url = "/smpl/smpl0103/" + result.last_mem_appr_seq;
			$M.goNextPage(url);
		}
		
		// 결재처리
		function fnApproval() {
			var param = {
				 'mem_appr_seq' : '${apprBean.mem_appr_seq}'
			 };
			openApprPanel('fnResultApproval', $M.toGetParam(param));
		}
		
	</script>
		<style>
		.smpl-div-left {
			float: left;
	    	width: 50%;
		}
	</style>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<h2>결재화면프로세스</h2>
			</div>
			<!-- /메인 타이틀 -->
			<h2>결재번호 : ${apprBean.last_mem_appr_seq }</h2>
			<div class="contents">
				<!-- 5dt div -->
				<div style="border: 1px solid skyblue;" class="smpl-div-left">
					<!-- 결재선 -->
					<div class="detail-left approval-left">
						<!-- 결재 작성상태 -->
						<span class="condition-item">상태 : ${apprBean.appr_proc_status_name}</span>
						<!-- /결재 작성상태 -->
					</div>
					<table class="table-border doc-table">
						<colgroup>
							<col width="52px">
							<col width="105px">
							<col width="105px">
							<col width="105px">
							<col width="105px">
						</colgroup>
						<tbody>
							<tr>						
								<th rowspan="2" class="title-bg th">결재선
									<c:if test="${apprBean.appr_modify_yn eq 'Y' }">
									<br><button type="button" class="btn btn-primary-gra" onclick="javascript:openApprSettingPanel()">관리</button>
									</c:if>
								</th>
								
								<c:forEach var="list" items="${apprList}" varStatus="status">
								<th class="th">
									<div class="approval-table">
										<div class="input-area">
											<input type="text" style="width: 100%;" id="apprName${status.count}" name="apprName${status.count}" value="${list.appr_mem_name}" readonly="readonly">
											<input type="hidden" id="apprNum${status.count}" name="apprNum${status.count}" value="${list.appr_mem_no}" readonly="readonly" class="checkMemNo">
											<c:if test="${status.count > 1 && apprBean.appr_modify_yn eq 'Y'}">
												<button type="button" class="icon-btn-search" onclick="javascript:fnPopMemName(this.value)" value="${status.count}"><i class="material-iconssearch"></i></button>
											</c:if>
										</div>
										<c:if test="${status.count > 1 && apprBean.appr_modify_yn eq 'Y'}">
										<div class="delete-area">
											<button type="button" class="icon-btn-close" onclick="javascript:fnMemNameDel(this.value)" value="${status.count}"><i class="material-iconsclose font-13 text-default"></i></button>
										</div>
										</c:if>
									</div>
								</th>
								</c:forEach>
								
							</tr>
							<tr>				
								<c:forEach var="list" items="${apprList}">
									<td class="text-center td" id="apprStatus${status.count}" name="apprStatus${status.count}">${list.appr_status_name }</td>
								</c:forEach>
							</tr>
						</tbody>			
					</table>
					<div class="btn-group">
						<div class="right">
							<c:if test="${apprBean.appr_modify_yn eq 'Y' }">
							<button type="button" class="btn btn-default" onclick="javascript:goSave('save');">결재선 저장</button>
							<button type="button" class="btn btn-default" onclick="javascript:goSave('apprSave');">결재요청</button>
							</c:if>
							<c:if test="${apprBean.appr_proc_yn eq 'Y' }">   
							<button type="button" class="btn btn-default" onclick="javascript:fnApproval();">결재처리</button>
							</c:if>
						</div>
					</div>
				</div>
				<!-- /5dt div -->
				<!-- 결재 -->
				<table class="table-border">
					<colgroup>
						<col width="15px">
						<col width="15px">
						<col width="15px">
						<col width="15px">
						<col width="20px">
						<col width="60px">
					</colgroup>
					<tbody>
						<tr>						
							<td>결재번호</td>
							<td>직원번호</td>
							<td>직원명</td>
							<td>결재상태</td>
							<td>처리일시</td>
							<td>의견</td>
						</tr>				
							<c:forEach var="list" items="${apprMemoList}">
							<tr>
								<td>${list.mem_appr_seq }</td>
								<td>${list.appr_mem_no }</td>
								<td>${list.appr_mem_name }</td>
								<td>${list.appr_status_name }</td>
								<td>${list.process_date }</td>
								<td>${list.memo }</td>
							</tr>
							
							</c:forEach>
					</tbody>			
				</table>
			</div>
		</div>
	</div>
<!-- /contents 전체 영역 -->
</div>	
</form>
</body>
</html>