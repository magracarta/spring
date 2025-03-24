<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<script type="text/javascript">

	$(document).ready(function() {
		__initButton();		// 버튼 세팅
		__fnSetMemNoStr();	// memNoStr
		$(".approval-table :input").prop("disabled", false);
	});
	
	function goPaper(name, no, refKey, popGetParam) {
		var menuName = "${page.menu_name}";
		menuName += " 메뉴에서 보낸쪽지입니다.#"
		+ "자료조회로 내용을 참고하세요.#"
		+ "#"
		+ "#";
		
		var jsonObject = {
			"paper_contents" : menuName,
			"ref_key" : refKey,
			"receiver_mem_no_str" : no,	// 수신자
			"refer_mem_no_str" : "",		// 참조자
			"menu_seq" : "${page.menu_seq}",
			"pop_get_param" : popGetParam,
			"cmd" : "N"
		}
    	openSendPaperPanel(jsonObject);
	}

	// 받아온 값 세팅할 name 구하는데 사용
	var nameStr 		= "apprName";
	var memNoStr 		= "apprNum";
	var apprStatusStr 	= "apprStatus";
	var apprWriterYnStr = "apprWriterYn"  // 전결여부
	// 받아온 값 세팅할 name
	var setName 		= "";	// 회원이름의 id명
	var setMemNo 		= "";	// 회원번호의 id명
	var setapprStatus	= "";	// 회원의 결재선 상태 id명
	var setWriterApprYn = "";  // 전결여부(세팅할때 N으로 세팅)
	var seqNum			= 0;	// 저장 및 삭제할 input의 번호
	
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
		
		// console.log("변경 - 이름 : " + rsName + " / 회원번호 : " + rsMemNo);
		
		rsCheck = __checkApprMember(rsName, rsMemNo);
		
		if(rsCheck == true) {
			// 저장할 name명 세팅
			setName 		= nameStr.concat(seqNum);
			setMemNo 		= memNoStr.concat(seqNum);
			setapprStatus 	= apprStatusStr.concat(seqNum);
			setWriterApprYn = apprWriterYnStr.concat(seqNum);
			
			// 결재선 라인에 값 세팅
			var frm 	= document.main_form;
			$M.setValue(frm, setName, rsName);
			$M.setValue(frm, setMemNo, rsMemNo);
			$M.setValue(frm, setWriterApprYn, "N");
			console.log(setWriterApprYn);
			
			$("#" + setapprStatus).text("처리전");
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
		// alert(JSON.stringify(result));
		var frm = document.main_form;
		var len = result.list.length;
		var num = 1;	// 세팅할 input name의 번호
		
		for(var i = 0; i < len; i++) {
			num = i+1;
			$M.setValue(frm, "apprName" + num, result.list[i].appr_mem_name);
			$M.setValue(frm, "apprNum" + num, result.list[i].appr_mem_no);
			$("#apprStatus" + num).text(result.list[i].appr_status_name);			

			// console.log(result.list[i].appr_mem_no);
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
		// console.log("삭제 - nameSeq : " + nameDel + " / memNoSeq : " + memNoDel);
		
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
		
		var tempWriterYnStr = [];
		var tWriterYn = 0;
		$(".apprWriterYn").each(function(i) {
			tWriterYn = $M.getValue($(this).attr("id"));
			tempWriterYnStr.push(tWriterYn);
		});
		var setApprWriterYnStr = $M.getArrStr(tempWriterYnStr);
		$M.setValue(frm, "writer_appr_yn_str", setApprWriterYnStr);
		
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
			if(checkVal == "") {
				$("#btnSearch" + num).css("display", "none");   
			} else {
				$("#btnSearch" + num).css("display", "block");   
			};
		});
	}
</script>
<style>
</style>
<!-- 결재선 -->
	<c:if test="${not empty apprBean}">
	<table class="table-border doc-table sm-table">
		<colgroup>
			<col width="80px">
			<col width="100px">
			<col width="100px">
			<col width="100px">
			<col width="100px">
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
							<c:choose>
								<c:when test="${not empty list.ref_key}">
									<input onclick="javascript:goPaper('${list.appr_mem_name}', '${list.appr_mem_no}', '${list.ref_key}', '${list.pop_get_param }')" type="text" style="width: 100%; text-align: right; margin-right: 7px; text-decoration: underline; cursor:pointer; text-underline-position: under;" id="apprName${status.count}" name="apprName${status.count}" value="${list.appr_mem_name}" readonly="readonly">	
								</c:when>
								<c:otherwise>
									<input type="text" style="width: 100%; text-align: right; margin-right: 7px;" id="apprName${status.count}" name="apprName${status.count}" value="${list.appr_mem_name}" readonly="readonly">
								</c:otherwise>
							</c:choose>
							
							<input type="hidden" id="apprNum${status.count}" name="apprNum${status.count}" value="${list.appr_mem_no}" readonly="readonly" class="apprLineMemNo">
							<!-- 직원검색 버튼 -->
							<c:if test="${status.count > 1 && apprBean.appr_modify_yn eq 'Y'}">
								<button type="button" class="icon-btn-search" onclick="javascript:__fnMemListPopup(this.value)" value="${status.count}" id="btnSearch${status.count}"> <i class="material-iconssearch"> </i></button>
							</c:if>
							<input type="hidden" id="apprWriterYn${status.count}" name="apprWriterYn${status.count}" value="${list.writer_appr_yn}" class="apprWriterYn">
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
					<td class="text-center td" id="apprStatus${status.count}" style="font-size: 12px !important;">${list.appr_status_name}</td>
				</c:forEach>
			</tr>
		</tbody>			
	</table>
	</c:if>
	<!-- /5dt div -->
<input type="hidden" name="appr_job_cd" id="appr_job_cd" value="${apprBean.appr_job_cd}" alt="결재업무" required="required"/>
<input type="hidden" name="appr_status_cd" id="appr_proc_status" value="${apprBean.appr_proc_status_cd}" alt="작업상태" required="required"/>
<input type="hidden" name="appr_mem_no_str" id="appr_mem_no_str" alt="결재라인" required="required"/>
<input type="hidden" name="auto_appr_yn" id="auto_appr_yn" alt="자동결재여부" value="${apprBean.auto_appr_yn}" required="required"/>
<input type="hidden" name="auto_appr_cnt" id="auto_appr_cnt" alt="자동결재대상수" value="${apprBean.auto_appr_cnt}" required="required"/>
<input type="hidden" name="appr_org_code_str" id="appr_org_code_str" alt="결재레벨부서" value="${apprBean.appr_org_code_str}"/>
<input type="hidden" name="appr_grade_str" id="appr_grade_str" alt="결재레벨직급" value="${apprBean.appr_grade_str}"/>
<input type="hidden" name="appr_mem_str" id="appr_mem_str" alt="결재레벨사용자" value="${apprBean.appr_mem_str}"/>
<input type="hidden" name="writer_appr_yn_str" id="writer_appr_yn_str" alt="전결가능여부"/>
<!-- /결재선 -->