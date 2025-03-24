<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 고객연관팝업 > 고객연관팝업 > null > 고객조회
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<script type="text/javascript">

	var auiGrid;
	var page = 1;
	var moreFlag = "N";
	var isLoading = false;
	
	// 품의서일 경우
	var machineDocYn = "${inputParam.machineDocYn}";

	// SA-R 미등록 장비만 조회하는 경우
	var sSarYn = "${inputParam.s_sar_yn ne 'Y' ? 'N' : 'Y'}"
	
	$(document).ready(function() {
		createAUIGrid();
		console.log("${SecureUser.web_id}");
		var custName = "${inputParam.s_cust_no}";
		var custYn = "${inputParam.s_cust_yn}";
		var consultYn = "${inputParam.s_consult_yn}";
		
		// var consultYn = "${inputParam.s_consult_yn}";
		// 입출금전표처리에서 고객조회 시 보유기종과 관계없이 1줄씩 조회되도록 함 //  Q&A 11505 안건상담등록 고객조회시 추가 210524 김상덕
		// 2021.10.12 Q&A 11505 안건상담등록 고객조회시 보유기종 체크 해제 추가. 
		if(custYn == "Y" || consultYn == "Y") {
		
		// 입출금전표처리에서 고객조회 시 보유기종과 관계없이 1줄씩 조회되도록 함
// 		if(custYn == "Y") {
			$("#s_machine_yn").prop("checked", false);
		}
		
		// 임의비용에서 조회할 경우
		var saleCustType = "${inputParam.s_cust_sale_type_cd}";
		if (saleCustType != "") {
			$("#s_cust_sale_type_cd_"+saleCustType).prop("checked", true);
		}	
		
		if (custName != "") {
			$M.setValue("s_cust_no", custName);
			goSearch();
		}
	});
	
	// 조회
	function goSearch() { 
		
		// 품의서에서 띄웠을경우 고객명, 휴대폰번호 필수
		if('${page.fnc.F00191_002}' != 'Y' && "Y" == machineDocYn) {
			if ($M.getValue('s_cust_no') == '' || $M.getValue('s_hp_no') == '') {
				alert('품의서 고객조회시 [고객명, 핸드폰번호] 는 필수입니다.');
				return false;
			}
		}

		if(sSarYn == 'Y') {
			if( $M.getValue('s_body_no') == '') {
				alert('차대번호는 필수입니다.');
				return;
			}
		} else {
			if( $M.getValue('s_cust_no') == '' && $M.getValue('s_breg_name') == '' && $M.getValue('s_hp_no') == '' && $M.getValue('s_breg_no') == '') {
				alert('[고객명, 업체명, 핸드폰번호, 사업자번호] 중 하나는 필수입니다.');
				return;
			}
		}
		var custNm = $M.getValue("s_cust_no");
		var hpTemp = $M.getValue('s_hp_no');
		if (hpTemp != '' && hpTemp.length < 8) {
			alert("핸드폰번호는 최소 8자리이상 입력하세요.");
			return false;
		}
		// 조회 버튼 눌렀을경우 1페이지로 초기화
		page = 1;
		moreFlag = "N";
		fnSearch(function(result) {
			AUIGrid.setGridData(auiGrid, result.list);
			$("#total_cnt").html(result.total_cnt);
			$("#curr_cnt").html(result.list.length);
			if (result.more_yn == 'Y') {
				moreFlag = "Y";
				page++;
			};
		});
	}

	//조회
	function fnSearch(successFunc) { 
		isLoading = true;
		var param = {
			"s_sort_key" : "cust_name",
			"s_sort_method" : "desc",
			"s_cust_no" : $M.getValue("s_cust_no"),
			"s_breg_name" : $M.getValue("s_breg_name"),
			"s_breg_no" : $M.getValue("s_breg_no"),
			"s_addr" : $M.getValue("s_addr"),
			"s_hp_no" : $M.getValue("s_hp_no"),
			"s_tel_no" : $M.getValue("s_tel_no"),
			"s_body_no" : $M.getValue("s_body_no"),
			"s_machine_name" : $M.getValue("s_machine_name"),
			"s_machine_plant_seq" : $M.getValue("s_machine_plant_seq"),
			"s_machine_yn" : $M.getValue("s_machine_yn"),
			"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
			"s_machine_doc_yn" : machineDocYn,
			"s_cust_sale_type_cd" : $M.getValue("s_cust_sale_type_cd"),
			"s_sar_yn" : sSarYn,
			"page" : page,
			"rows" : $M.getValue("s_rows"),
      "s_client_yn" : $M.getValue("s_client_yn"),
		};
		$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
			function(result) {
				isLoading = false;
				if(result.success) {
					successFunc(result);
				};
			}
		);
	}
	
	// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
	function fnScollChangeHandelr(event) {
		if(event.position == event.maxPosition && moreFlag == "Y"  && isLoading == false) {
			goMoreData();
		};
	}
	
	function goMoreData() {
		fnSearch(function(result){
			result.more_yn == "N" ? moreFlag = "N" : page++;  
			if (result.list.length > 0) {
				console.log(result.list);
				AUIGrid.appendData("#auiGrid", result.list);
				$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
			};
		});
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_cust_no", "s_breg_name", "s_breg_no", "s_addr", "s_hp_no", "s_tel_no", "s_body_no", "s_machine_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch(document.main_form);
			};
		});
	}
	
	function createAUIGrid() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "_$uid",
			// 고정칼럼 카운트 지정
			// fixedColumnCount : 3,
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
		};
		var columnLayout = [
			// 고객명	업체명 사업자번호 휴대폰 전화번호	팩스	주소	모델	차대번호 미수금 수주 정비 회원구분	동의여부 광고수신거부
			{
				headerText : "고객명",
				dataField : "cust_name",
				width : 100,
				style : "aui-center"
			},
			{
				headerText : "업체명",
				dataField : "breg_name",
				width : 110,
				style : "aui-center"
			},
			{
				dataField : "real_cust_name",
				visible : false
			},
			{
				dataField : "real_hp_no",
				visible : false
			},
			{
				headerText : "사업자번호",
				dataField : "breg_no",
				width : 140,
				style : "aui-center"
			},
			{
				headerText : "휴대폰",
				dataField : "hp_no",
				width : 110,
				style : "aui-center",
			},
			{
				headerText : "전화번호",
				dataField : "tel_no",
				width : 100,
				style : "aui-center",
			},
			{
				headerText : "팩스",
				dataField : "fax_no",
				width : 100,
				style : "aui-center"
			},
			{
				headerText : "주소",
				dataField : "addr",
				width : 400,
				style : "aui-left"
			},
			{
				headerText : "모델",
				dataField : "machine_name",
				width : 100,
				style : "aui-center"
			},
			{
				headerText : "차대번호",
				dataField : "body_no",
				width : 150,
				style : "aui-center"
			},
			{
				headerText : "회계거래처코드",
				dataField : "account_link_cd",
				width : 100,
				style : "aui-center"
			},
 			{
				headerText : "미수금",
				dataField : "misu_amt",
				dataType : "numeric",
				formatString : "#,##0",
				width : 100,
				style : "aui-right"
			},
 			{
				headerText : "수주",
				dataField : "part_sale_no",
				width : 100,
				style : "aui-center"
			},
 			{
				headerText : "수주일자",
				dataField : "sale_dt",
				dataType : "date",
				formatString : "yyyy-mm-dd",
				visible : false
			},
			{
				headerText : "정비",
				dataField : "job_report_no",
				width : 110,
				style : "aui-center"
			},
			{
				headerText : "회원구분",
				dataField : "cust_type_name",
				width : 100,
				style : "aui-center"
			},
			{
				dataField : "cust_type_cd",
				visible : false
			},
			{
				headerText : "동의여부",
				dataField : "personal_yn",
				width : 100,
				style : "aui-center"
			},
			{
				headerText : "광고수신거부",
				dataField : "marketing_yn",
				width : 100,
				style : "aui-center"
			},
			{
				headerText : "마케팅담당",
				dataField : "sale_mem_name",
				visible : false
			},
			{
				headerText : "마케팅구역코드",
				dataField : "sale_area_code",
				visible : false
			},
			{
				headerText : "마케팅구역명",
				dataField : "area_si",
				visible : false
			},
			{
				dataField : "addr1",
				visible : false
			},
			{
				dataField : "addr2",
				visible : false
			},
			{
				dataField : "breg_seq",
				visible : false
			},
			{
				dataField : "real_breg_no",
				visible : false
			},
			{
				dataField : "sale_ability_hmb",
				visible : false
			},
			{
				dataField : "sale_contract_dt",
				visible : false
			},
			{
				dataField : "sale_contract_ed_dt",
				visible : false
			},
			{
				dataField : "cust_grade_cd",
				visible : false
			},
			{
				dataField : "cust_grade_desc",
				visible : false
			}
		]
		if(sSarYn == "Y") {
			columnLayout = [
				// 고객명	업체명 사업자번호 휴대폰 전화번호	팩스	주소	모델	차대번호 미수금 수주 정비 회원구분	동의여부 광고수신거부
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : 100,
					style : "aui-center"
				},
				{
					headerText : "업체명",
					dataField : "breg_name",
					width : 110,
					style : "aui-center"
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					width : 150,
					style : "aui-center"
				},
				{
					headerText : "품의번호",
					dataField : "machine_doc_no",
					width : 150,
					style : "aui-center"
				},
				{
					dataField : "real_cust_name",
					visible : false
				},
				{
					dataField : "real_hp_no",
					visible : false
				},
				{
					headerText : "사업자번호",
					dataField : "breg_no",
					width : 140,
					style : "aui-center"
				},
				{
					headerText : "휴대폰",
					dataField : "hp_no",
					width : 110,
					style : "aui-center",
				},
				{
					headerText : "전화번호",
					dataField : "tel_no",
					width : 100,
					style : "aui-center",
				},
				{
					headerText : "팩스",
					dataField : "fax_no",
					width : 100,
					style : "aui-center"
				},
				{
					headerText : "주소",
					dataField : "addr",
					width : 400,
					style : "aui-left"
				},
				{
					headerText : "모델",
					dataField : "machine_name",
					width : 100,
					style : "aui-center"
				},
				{
					headerText : "회계거래처코드",
					dataField : "account_link_cd",
					width : 100,
					style : "aui-center"
				},
				{
					headerText : "미수금",
					dataField : "misu_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : 100,
					style : "aui-right"
				},
				{
					headerText : "수주",
					dataField : "part_sale_no",
					width : 100,
					style : "aui-center"
				},
				{
					headerText : "수주일자",
					dataField : "sale_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					visible : false
				},
				{
					headerText : "정비",
					dataField : "job_report_no",
					width : 110,
					style : "aui-center"
				},
				{
					headerText : "회원구분",
					dataField : "cust_type_name",
					width : 100,
					style : "aui-center"
				},
				{
					dataField : "cust_type_cd",
					visible : false
				},
				{
					headerText : "동의여부",
					dataField : "personal_yn",
					width : 100,
					style : "aui-center"
				},
				{
					headerText : "광고수신거부",
					dataField : "marketing_yn",
					width : 100,
					style : "aui-center"
				},
				{
					headerText : "마케팅담당",
					dataField : "sale_mem_name",
					visible : false
				},
				{
					headerText : "마케팅구역코드",
					dataField : "sale_area_code",
					visible : false
				},
				{
					headerText : "마케팅구역명",
					dataField : "area_si",
					visible : false
				},
				{
					dataField : "addr1",
					visible : false
				},
				{
					dataField : "addr2",
					visible : false
				},
				{
					dataField : "breg_seq",
					visible : false
				},
				{
					dataField : "real_breg_no",
					visible : false
				},
				{
					dataField : "sale_ability_hmb",
					visible : false
				},
				{
					dataField : "sale_contract_dt",
					visible : false
				},
				{
					dataField : "sale_contract_ed_dt",
					visible : false
				},
				{
					dataField : "cust_grade_cd",
					visible : false
				},
				{
					dataField : "cust_grade_desc",
					visible : false
				},
				{
					dataField : "total_mile_amt",
					visible : false
				}
			]
		}
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
		AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			// Row행 클릭 시 반영
			try{
				if (event.item.breg_no != null && event.item.real_breg_no != null) {
					event.item.breg_no = event.item.real_breg_no;	
				}
				<c:if test="${inputParam.parent_js_name eq 'goNewDoc'}">
				if (confirm("["+event.item.real_cust_name+"] 고객으로 품의서를 작성하시겠습니까?") == false) {
					return false;
				}
				</c:if>
				opener.${inputParam.parent_js_name}(event.item);
				// 23.03.07 정윤수 row 클릭할때마다 추가될 수 있도록 추가
				if("${inputParam.multi_yn}" != "Y"){
					window.close();
				}
			} catch(e) {
				alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
			}
		});	
		$("#auiGrid").resize();
	}
	
	//모델조회
	function setModelInfo(row) {
// 		alert(JSON.stringify(row));
		$M.setValue("s_machine_name", row.machine_name);
	}
	
	//팝업 끄기
	function fnClose() {
		window.close(); 
	}

</script>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 (문자발송) -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	  
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="110px">
						<col width="150px">
						<col width="70px">
						<col width="150px">
						<col width="80px">
						<col width="160px">
						<col width="60px">
						<col width="170px">
						<col width="110px">
						<col width="10px">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th>고객명 / 고객번호</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_cust_no" name="s_cust_no" class="form-control" placeholder="고객명 / 고객번호">
								</div>
							</td>
							<th>업체명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_breg_name" name="s_breg_name" class="form-control">
								</div>
							</td>
							<th>사업자번호</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_breg_no" name="s_breg_no" class="form-control" placeholder="-없이 숫자만" datatype="int">
								</div>
							</td>
							<th>주소</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_addr" name="s_addr" class="form-control">
								</div>
							</td>
							<td class="text-right" colspan="2">
								<div class="inlineBlock ${inputParam.s_sar_yn ne 'Y' ? '' : 'dpn'}">
									<span>구분</span>
									<label><input type="radio" name="s_cust_sale_type_cd" checked="checked" value="" id="">전체</label>
									<label><input type="radio" name="s_cust_sale_type_cd" value="00" id="s_cust_sale_type_cd_00">일반</label>
									<label><input type="radio" name="s_cust_sale_type_cd" value="10" id="s_cust_sale_type_cd_10">모니터</label>
									<label><input type="radio" name="s_cust_sale_type_cd" value="20" id="s_cust_sale_type_cd_20">서브</label>
								</div>
							</td>
						</tr>
						<tr>
							<th>휴대폰</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_hp_no" name="s_hp_no" class="form-control" placeholder="-없이 숫자만" datatype="int">
								</div>
							</td>
							<th>전화</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_tel_no" name="s_tel_no" class="form-control" placeholder="-없이 숫자만" datatype="int">
								</div>
							</td>
							<th>차대번호</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_body_no" name="s_body_no" class="form-control">
								</div>
							</td>
							<th>모델</th>
							<td>
								<div class="form-row">
									<div class="col-12">
<!-- 										<div class="input-group"> -->
<!-- 											<input type="text" id="s_machine_name" name="s_machine_name" class="form-control border-right-0"> -->
<!-- 											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchModelPanel('setModelInfo', 'N');"><i class="material-iconssearch"></i></button>											 -->
<!-- 										</div> -->
										<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
				                     		<jsp:param name="required_field" value=""/>
				                     		<jsp:param name="s_maker_cd" value=""/>
				                     		<jsp:param name="s_machine_type_cd" value=""/>
				                     		<jsp:param name="s_sale_yn" value=""/>
				                     		<jsp:param name="readonly_field" value=""/>
				                     		<jsp:param name="execFuncName" value=""/>
				                     		<jsp:param name="focusInFuncName" value=""/>
				                     	</jsp:include>
									</div>
								</div>			
							</td>
							<th class="text-right">
								<div class="form-check form-check-inline ${inputParam.s_sar_yn ne 'Y' ? '' : 'dpn'}" >
									<label class="form-check-label mr5" for="s_machine_yn">보유기종별</label>
									<input class="form-check-input" type="checkbox" id="s_machine_yn" name="s_machine_yn" checked="checked" value="Y">
								</div>
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								</div>
								</c:if>
                <%-- q&a - 23628 매입처 필터 추가 --%>
                <c:if test="${page.fnc.F00191_003 eq 'Y'}">
                  <div class="form-check form-check-inline">
                    <label  class="form-check-input"  for="s_masking_yn" >매입처 적용</label>
                    <input  class="form-check-input"  type="checkbox" id="s_client_yn" name="s_client_yn" value="Y"/>
                  </div>
                </c:if>
              </th>
							<td class="text-right"><button type="button" class="btn btn-important" style="width: 60px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
<!-- 검색결과 -->
			
			<div id="auiGrid" style="margin-top: 5px; height: 600px;"></div>
			
			<div class="btn-group mt5">	
				<div class="left">
					<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
				</div>						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /검색결과 -->
        </div>
    </div>
    </form>
<!-- /팝업 (문자발송) -->
	
</body>
</html>