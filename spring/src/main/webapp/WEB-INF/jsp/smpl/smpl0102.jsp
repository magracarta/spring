<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	$(document).ready(function() {
		__initButton();		// 버튼 세팅
		__fnSetMemNoStr();	// memNoStr
	});
	
	$(window).load(function() {
	});

	// 받아온 값 세팅할 name 구하는데 사용
	var nameStr 		= "apprName";
	var memNoStr 		= "apprNum";
	var apprStatusStr 	= "apprStatus";
	// 받아온 값 세팅할 name
	var setName 	= "";	// 회원이름의 name명
	var setMemNo 	= "";	// 회원번호의 name명
	var seqNum		= 0;	// 저장 및 삭제할 input의 번호
	
	// 직원조회 팝업 호출 버튼값을 받아옴(세팅할 inputBox row Num)
	function __fnMemListPopup(num) {
		seqNum = num;
		openSearchMemberPanel("__fnSetApprMember");
	}
	
	// 직원조회 결과 데이터 받아서 세팅 
	function __fnSetApprMember(result) {
		var rsName 	= result.mem_name;
		var rsMemNo = result.mem_no;
		var rsCheck = true;		// 중복체크 결과
		
		console.log("변경 - 이름 : " + rsName + " / 회원번호 : " + rsMemNo);
		
		rsCheck = __checkApprMember(rsName, rsMemNo);
		
		if(rsCheck == true) {
			// 저장할 name명 세팅
			setName 	= nameStr.concat(seqNum);
			setMemNo 	= memNoStr.concat(seqNum);
			// 결재선 라인에 값 세팅
			var frm 	= document.main_form;
			$M.setValue(frm, setName, rsName);
			$M.setValue(frm, setMemNo, rsMemNo);
			// 결재선 세팅된 memNo들 히든값에 저장
			__fnSetMemNoStr();
			__initButton();
		} else if(rsCheck == false) {
			alert("결재선 이름 중복 다시등록해주세요");
		};
		
	}
	
	// 직원조회 결과 데이터 중복검사
	function __checkApprMember(rsName, rsMemNo) {
		var checkMemStr = [];		// 세팅된 mem_no
		var checkVal 	= "";		// 중복체크 할 mem_no 값
		var checkResult = true;		// 중복값 있으면 false로 변경
		
		// class이름을 통해 mem_no 가져옴(기존에 넣어져있는 값)
		$(".apprLineMemNo").each(function(i) {
			checkVal = $M.getValue($(this).attr("id"));
			checkMemStr.push(checkVal);
		});

		// 기존에 넣어져있는 mem_no값들과 새로 등록할 mem_no 값 비교
		if($.inArray(rsMemNo, checkMemStr) != -1) {
			checkResult = false;
		};
		return checkResult;
	}
	
	// 결재선관리 팝업호출
	function fnApprSetPopup(apprJobCd) {
		var param = {
			"s_appr_job_cd" : apprJobCd
		};
		openApprLinePanel("__fnSetApprLine", $M.toGetParam(param));
	}
	
	// 결재선관리 팝업에서 선택한 결재선라인 세팅 
	function __fnSetApprLine(result) {
		var frm = document.main_form;
		var len = result.list.length;
		var num = 1;	// 세팅할 input name의 번호
		
		for(var i = 0; i < len; i++) {
			num = i+1;
			$M.setValue(frm, "apprName" + num, result.list[i].appr_mem_name);
			$M.setValue(frm, "apprNum" + num, result.list[i].appr_mem_no);
			// 2번째 결재선부터 기존상태 초기화
			if(num > 1) {
				$("#apprStatus" + num).text("");			
			}
			console.log(result.list[i].appr_mem_no);
		}
		// 결재선 세팅된 memNo들 히든값에 저장
		__fnSetMemNoStr();	
		__initButton();
	}
	
	// x 버튼 클릭 시 inputbox 초기화
	function __fnMemNameDel(seqNum) {
		var frm = document.main_form;
		var nameDel 	= nameStr.concat(seqNum);
		var memNoDel 	= memNoStr.concat(seqNum);
		var statusDel 	= apprStatusStr.concat(seqNum);
		console.log("삭제 - nameSeq : " + nameDel + " / memNoSeq : " + memNoDel);
		
		$M.setValue(frm, nameDel, "");
		$M.setValue(frm, memNoDel, "");
		$("#"+statusDel).text("");
		
		__fnSetMemNoStr();
		__initButton();
	}
	
	// 결재선라인 세팅
	function __fnSetMemNoStr() {
		var apprMemNoStr = [];		// mem_no
		var apprMemNo	 = 0;		// memNo
		
		// 결재선 라인에 세팅된 값들 appr_mem_no_str에 #처리하여 저장
		$(".apprLineMemNo").each(function(i) {
			apprMemNo = $M.getValue($(this).attr("id"));
			apprMemNoStr.push(apprMemNo);
		});
		var setApprMemNoStr = $M.getArrStr(apprMemNoStr);
		var frm 	= document.main_form;
		$M.setValue(frm, "appr_mem_no_str", setApprMemNoStr);
		console.log($M.getValue("appr_mem_no_str"), "#######");
	}
	
	// 버튼 display
	function __initButton() {
		// 해당 번호에 값이 없을때 x버튼 숨김 or 해당번호 다음번호에 값이 있으면 x버튼 숨김		
		$(".apprLineMemNo").each(function(i) {
			var checkVal = $M.getValue($(this).attr("id"));
			var num = i+1;	// 해당 번호
			
			var nextSeqNum 		= parseInt(num) + 1;					// 다음번호
			var checkNextVal 	= $M.getValue("apprNum" + nextSeqNum);	// 다음번호의 값 

			if(checkVal == "" || checkNextVal != "") {
				$("#btnDelete" + num).css("display", "none");   
			} else {
				$("#btnDelete" + num).css("display", "block");   
			};

		});
		
		// 앞번호에 값이 없으면 검색버튼 숨김
		$(".apprLineMemNo").each(function(i) {
			var checkVal = $M.getValue($(this).attr("id"));
			var num = i+2;
			if(checkVal == "" && num < 5) {
				$("#btnSearch" + num).css("display", "none");   
			} else {
				$("#btnSearch" + num).css("display", "block");   
			};
		});
	}
	</script>
	<style>
		.smpl-div-left {
			float: left;
	    	width: 50%;
		}
	</style>
</head>
<body>
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
					<div class="contents">
						<!-- 5dt div -->
						<div style="border: 1px solid skyblue;" class="smpl-div-left">
							<!-- 결재선 -->
							<div class="detail-left approval-left">
								<!-- 결재 작성상태 -->
								<span class="condition-item">상태 : ${apprBean.appr_proc_status_name}</span>
								<!-- /결재 작성상태 -->
							</div>
							<!-- 결재선 -->
							<table class="table-border doc-table sm-table">
								<colgroup>
									<col width="60px">
									<col width="80px">
									<col width="80px">
									<col width="80px">
									<col width="80px">
								</colgroup>
								<tbody>
									<tr>						
										<th rowspan="2" class="title-bg th" style="padding: 6px;">
											<span class="v-align-middle" style="font-size: 12px !important;">결재선</span>
											<c:if test="${apprBean.appr_modify_yn eq 'Y' }">
											<button type="button" class="btn btn-primary-gra btn-sm" onclick="javascript:fnApprSetPopup('${apprBean.appr_job_cd}')">관리</button>
											</c:if>
										</th>
										<c:forEach var="list" items="${apprList}" varStatus="status">
										<th class="th">
											<div class="approval-table">
												<div class="input-area">
													<input type="text" style="width: 100%; text-align: right; margin-right: 7px;" id="apprName${status.count}" name="apprName${status.count}" value="${list.appr_mem_name}" readonly="readonly">
													<input type="hidden" id="apprNum${status.count}" name="apprNum${status.count}" value="${list.appr_mem_no}" readonly="readonly" class="apprLineMemNo">
													<!-- 직원검색 버튼 -->
													<c:if test="${status.count > 1 && apprBean.appr_modify_yn eq 'Y'}">
														<button type="button" class="icon-btn-search" onclick="javascript:__fnMemListPopup(this.value)" value="${status.count}" id="btnSearch${status.count}"> <i class="material-iconssearch"> </i></button>
													</c:if>
													<!-- /직원검색 버튼 -->
												</div>
												<c:if test="${status.count > 1 && apprBean.appr_modify_yn eq 'Y'}">
												<div class="delete-area">
													<button type="button" class="icon-btn-close" onclick="javascript:__fnMemNameDel(this.value)" value="${status.count}" id="btnDelete${status.count}"><i class="material-iconsclose"></i></button>
												</div>
												</c:if>
											</div>
										</th>
										</c:forEach>
									</tr>
									<tr>				
										<c:forEach var="list" items="${apprList}" varStatus="status">
											<td class="text-center td" id="apprStatus${status.count}" name="apprStatus${status.count}" style="font-size: 12px !important;">${list.appr_status_name}</td>
										</c:forEach>
									</tr>
								</tbody>			
							</table>
							<div class="btn-group">
								<div class="right">
									<button type="button" class="btn btn-default" onclick="javascript:goSave('save');">결재선 저장</button>
									<button type="button" class="btn btn-default" onclick="javascript:goSave('apprSave');">결재요청</button>
								</div>
							</div>
							<!-- /5dt div -->
							
							<br>
							<div class="btn-group">
								<div class="right">
									<select id="s_appr_job_cd" name="s_appr_job_cd" style="width: 150px; height: 20px" alt="결재업무코드">
										<option value="">- 선택 -</option>
										<c:forEach var="list" items="${codeMap['APPR_JOB']}">
											<option value="${list.code_value}" ${inputParam.s_appr_job_cd eq list.code_value ? 'selected' : '' }>${list.code_name}</option>
										</c:forEach>
									</select>
									<button type="button" class="btn btn-default" onclick="javascript:goSearch();">결재업무 조회</button>
								</div>
							</div>
						</div>
						<!-- /결재선 -->
		
					</div>
				</div>
			</div>
		<!-- /contents 전체 영역 -->
		</div>	
	</form>
</body>
</html>