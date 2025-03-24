<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 매입처관리 > 매입처등록 > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function () {
			fnSelectOrg('${SecureUser.org_code}')
		});
	
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return;
			};
			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {
							history.back();
						}
					}
				);
		}
		
		function fnList() {
			history.back();
		}
		
		// 주소팝업 test
		function fnJusoBiz(data) {
			$M.setValue("post_no", data.zipNo);
			$M.setValue("addr1", data.roadAddrPart1);
			$M.setValue("addr2", data.addrDetail);
			$M.setValue("engAddr", data.engAddr);
		}
		
		// 사업자정보조회 결과 test
		function fnSetBregInfo(row) {
			$M.setValue("breg_no", row.breg_no);
			$M.setValue("breg_seq", row.breg_seq);
			$M.setValue("breg_name", row.breg_name);
			$M.setValue("breg_rep_name", row.breg_rep_name);
			$M.setValue("breg_cor_type", row.breg_cor_type);
			$M.setValue("breg_cor_part", row.breg_cor_part);
		}
		
		// 관리담당 팝업
		function fnSetMemberInfo(row) {
			$M.setValue("mng_mem_name", row.mem_name);
			$M.setValue("mng_mem_no", row.mem_no);

			fnSelectOrg(row.org_code)	// 관리부서와 연동
		}

		// 관리부서 -> 관리당담에 맞는 부서로 세팅, 없을 시 선택
		function fnSelectOrg (orgCode) {
			var orgList = document.getElementById('mng_org_code');
			var isOrgList = false;
			orgCode = orgCode.substring(0,1) == 5 ? '5000' : orgCode;   // 서비스&서비스하위 센터들은 관리부서가 '서비스/센터'로
			for (var i = 0; i < orgList.options.length; i++) {
				if (orgList.options[i].value == orgCode) {
					orgList.selectedIndex = i;
					isOrgList = true;
					break;
				}
			}
			// 관리담당자의 부서가 orgList에 없는 경우, '- 선택 -'으로 설정
			if (!isOrgList) {
				orgList.selectedIndex = 0;
			}
		}

		// 화폐단위
		function fnMoneyUnitChange() {
			var param = {
				"money_unit_cd": $M.getValue("money_unit_cd")
			}
			$M.goNextPageAjax('/part/part0301p01' + '/' + param.money_unit_cd + '/money', $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						var data = result.money_unit;
						$M.setValue("money_unit", data);
					};
				}
			);
		}
		
		// 거래원장조회 예비
		function testSearchCust() {
			if($M.getValue("cust_no") == "") {
				alert("고객 정보가 없습니다.");
				return false;
			}
			var param = {
					"s_cust_no" : $M.getValue("cust_no")
			};
			$M.goNextPage('/part/part0303p01', $M.toGetParam(param), {popupStatus : getPopupProp(1550, 860)});
		}
		
		// 상세내역 팝업
		function fnSelectCustClientPartNoList() {
			var param = {
					"cust_no" : ""
			};
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
			$M.goNextPage('/part/part0301p02',  $M.toGetParam(param), {popupStatus : popupOption});
					
		}
		
		// 사업자정보조회 팝업
		function fnSearchBregInfo() {
			var param = {
			};
			openSearchBregInfoPanel('fnSetBregInfo', $M.toGetParam(param));
		}

		// 관리담당정보 초기화
		function fnDeleteMngName() {
			$M.setValue("mng_mem_name", "");
			$M.setValue("mng_mem_no", "");
			$M.setValue("mng_org_code", "");
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="cust_no" id="cust_no" value="">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 상단 폼테이블 -->					
					<div>
						<table class="table-border" style="width:75%;">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
								<col width="90px">
								<col width="">
								<col width="90px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right essential-item">업체그룹</th>
									<td>
										<select class="form-control width140px essential-bg" id="com_buy_group_cd" name="com_buy_group_cd" alt="업체그룹" required="required">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['COM_BUY_GROUP']}">
											<option value="${item.code_value}">${item.code_desc}</option>
											</c:forEach>
										</select>
									</td>	
									<th class="text-right essential-item">업체명</th>
									<td>
										<input type="text" class="form-control width120px essential-bg" id="cust_name" name="cust_name" alt="업체명" required="required">
									</td>	
									<th class="text-right">관리담당</th>
									<td>
									<div class="input-group width120px">
											<input type="text" class="form-control width120px border-right-0" id="mng_mem_name" name="mng_mem_name" value="${SecureUser.user_name}" alt="관리담당" readonly>
											<input type="hidden" id="mng_mem_no" name="mng_mem_no" value="${SecureUser.mem_no}">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchMemberPanel('fnSetMemberInfo');"><i class="material-iconssearch"></i></button>
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="fnDeleteMngName()"><i class="material-iconsclose"></i></button>
										</div>
									</td>	
									<th class="text-right">매입구분</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="nation_type_d" name="nation_type_df" value="D">
											<label class="form-check-label">내자</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="nation_type_f" name="nation_type_df" value="F">
											<label class="form-check-label">외자</label>
										</div>
									</td>							
								</tr>
								<tr>
									<th class="text-right">송금조건/일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-8">
												<input type="text" class="form-control width120px" id="send_money_text" name="send_money_text" alt="송금조건">
											</div>
											/&nbsp;&nbsp;
											<div class="col-2">
												<input type="text" class="form-control width40px" id="send_money_day_cnt" name="send_money_day_cnt" alt="송금조건일" format="num">
											</div>
										</div>
									</td>
									<th class="text-right">고객풀네임</th>
									<td>
										<input type="text" class="form-control width120px" id="cust_full_name" name="cust_full_name" alt="고객풀네임">
									</td>
									<th class="text-right">회계거래처코드</th>
									<td>
										<input type="text" class="form-control width120px" id="account_link_cd" name="account_link_cd" value="${result.account_link_cd}">
									</td>
									<th class="text-right">관리부서</th>
									<td>
										<select class="form-control width100px" id="mng_org_code" name="mng_org_code">
											<option value="">- 선택 -</option>
											<c:forEach var="item" items="${orgList}">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
									</td>
									
								</tr>
								<tr>
									<th class="text-right">사업자번호</th>
										<td colspan="3">
											<div class="form-row inline-pd">
												<div class="col-3">
													<div class="input-group">
														<input type="text" class="form-control width120px border-right-0" id="breg_no" name="breg_no" value="" readonly="readonly" alt="사업자번호">
														<input type="hidden" class="form-control border-right-0" id="breg_seq" name="breg_seq" value="" readonly="readonly">
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchBregInfo();"><i class="material-iconssearch"></i></button>	
													</div>
												</div>
												<div class="col-3">
													<input type="text" class="form-control width120px" id="breg_name" name="breg_name" value="" readonly="readonly">
												</div>	
												<div class="col-6">
													<input type="text" class="form-control width120px" id="breg_rep_name" name="breg_rep_name" value="" readonly="readonly">
												</div>									
											</div>
										</td>
									<th rowspan="3" class="text-right">주소</th>
									<td colspan="3" rowspan="3">
										<div class="form-row inline-pd mb7">
											<div class="col-3">
												<input type="text" class="form-control width100px" id="post_no" name="post_no">
											</div>
											<div class="col-3">
												<button type="button" class="btn btn-primary-gra" onclick="javascript:openSearchAddrPanel('fnJusoBiz');">주소찾기</button>
											</div>
										</div>
										<div class="form-row inline-pd mb7">
											<div class="col-12">
												<input type="text" class="form-control width280px" id="addr1" name="addr1">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control width280px" id="addr2" name="addr2">
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">업태</th>
									<td>
										<input type="text" class="form-control width120px" id="breg_cor_type" name="breg_cor_type" value="" readonly="readonly">
									</td>	
									<th class="text-right">업종</th>
									<td>
										<input type="text" class="form-control width120px" id="breg_cor_part" name="breg_cor_part" value="" readonly="readonly">
									</td>	
								</tr>
								<tr>
									<th class="text-right">휴대폰</th>
									<td>
										<input type="text" class="form-control width140px" placeholder="숫자만 입력" id="hp_no" name="hp_no" format="tel" alt="휴대폰">
									</td>
									<th class="text-right">전화번호</th>
									<td>
										<input type="text" class="form-control width140px" placeholder="하이픈(-) 포함" id="tel_no" name="tel_no">
									</td>	
								</tr>
								<tr>
									<th class="text-right">팩스</th>
									<td>
										<input type="text" class="form-control width140px" placeholder="하이픈(-) 포함" id="fax_no" name="fax_no">
									</td>	
									<th class="text-right">이메일</th>
									<td>
										<input type="text" class="form-control width140px" id="email" name="email">
									</td>
									<th class="text-right">거래은행</th>
									<td>
										<input type="text" class="form-control width120px" id="bank_name" name="bank_name">
									</td>
									<th class="text-right">계좌번호</th>
									<td>
										<input type="text" class="form-control width140px" id="account_no" name="account_no">
									</td>								
								</tr>
								<tr>
									<th class="text-right">마케팅담당자명</th>
									<td>
										<input type="text" class="form-control width120px" id="charge_name" name="charge_name">
									</td>
									<th class="text-right">마케팅담당직책</th>
									<td>
										<input type="text" class="form-control width120px" id="charge_grade" name="charge_grade">
									</td>
									<th class="text-right">예금주</th>
									<td  colspan="3">
										<input type="text" class="form-control width-100per" id="client_deposit_name" name="client_deposit_name" value="${result.client_deposit_name}">
									</td>
								</tr>
								<tr>
									<th class="text-right">마케팅담당휴대폰</th>
									<td>
										<input type="text" class="form-control width140px" id="charge_hp_no" name="charge_hp_no" placeholder="숫자만 입력" format="phone" maxlength="11">
									</td>
									<th class="text-right">마케팅담당이메일</th>
									<td>
										<input type="text" class="form-control width140px" id="charge_email" name="charge_email">
									</td>
								</tr>
							</tbody>
						</table>
					</div>					
		<!-- /상단 폼테이블 -->	
		<!-- 하단 폼테이블 -->
					<div class="row" style="width:75%;">
		<!-- 구매조건 -->	
						<div class="col-4">
							<div class="title-wrap mt10">
								<h4>구매조건</h4>									
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">거래외환</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-4">
													<select class="form-control width100px" id="money_unit_cd" name="money_unit_cd" onchange="fnMoneyUnitChange()">
														<c:forEach var="item" items="${codeMap['MONEY_UNIT']}">
														<option value="${item.code_value}">${item.code_value}</option>
														</c:forEach>
													</select>
												</div>
												<div class="col-8">
													<input type="text" class="form-control width100px" id="money_unit" name="money_unit" value="${item.code_value}" readonly="readonly" style="background-color:#FFF;">
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">지불조건</th>
										<td>
											<select class="form-control width100px essential-bg" alt="지불조건" id="out_case_cd" name="out_case_cd" required="required">
												<option value="">- 선택 -</option>
												<c:forEach var="item" items="${codeMap['OUT_CASE']}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:forEach>
											</select>
										</td>
									</tr>
									<tr>
										<th class="text-right">PPM</th>
										<td>
											<input type="text" class="form-control width120px" id="ppm" name="ppm">
										</td>
									</tr>
									<tr>
										<th class="text-right">Inconterms</th>
										<td>
											<input type="text" class="form-control width120px" id="incoterms" name="incoterms">
										</td>
									</tr>
									<tr>
										<th class="text-right">계약L/T</th>
										<td>
											<input type="text" class="form-control width120px" id="lead_time" name="lead_time" placeholder="숫자만 입력" datatype="int">
										</td>
									</tr>
									<tr>
										<th class="text-right">납기율</th>
										<td>
											<input type="text" class="form-control width120px" id="delivery_rate" name="delivery_rate">
										</td>
									</tr>
								</tbody>
							</table>
						</div>
		<!-- /구매조건 -->
		<!-- 업체관리 -->
						<div class="col-4">
							<div class="title-wrap mt10">
								<h4>업체관리</h4>									
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">계약서</th>
										<td>
											<select class="form-control width100px" id="contract_mng_cd" name="contract_mng_cd">
												<option value="">- 선택 -</option>
												<c:forEach var="item" items="${codeMap['CONTRACT_MNG']}">
												<option value="${item.code_value}">${item.code_name}</option>
												</c:forEach>
											</select>
										</td>
									</tr>
									<tr>
										<th class="text-right">금형관리</th>
										<td>
											<select class="form-control width100px" id="kuemhng_yn" name="kuemhng_yn">
												<option value="">- 선택 -</option>
												<option value="Y">Y</option>
												<option value="N">N</option>
											</select>
										</td>
									</tr>
									<tr>
										<th class="text-right">도면관리</th>
										<td>
											<select class="form-control width100px" id="domuen_yn" name="domuen_yn">
												<option value="">- 선택 -</option>
												<option value="Y">Y</option>
												<option value="N">N</option>
											</select>
										</td>
									</tr>
									<tr>
										<th class="text-right">입고품질검사</th>
										<td>
											<select class="form-control width100px" id="ware_qual_cd" name="ware_qual_cd">
												<option value="">- 선택 -</option>
												<c:forEach var="item" items="${codeMap['WARE_QUAL']}">
												<option value="${item.code_value}">${item.code_name}</option>
												</c:forEach>
											</select>
										</td>
									</tr>
									<tr>
										<th class="text-right">업체평가</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-6">
													<input type="text" class="form-control width120px" value="" id="point_case" name="point_case">
												</div>
												<div class="col-6">
													<button type="button" class="btn btn-primary-gra" style="width: 120px;" onclick="javascript:testSearchCust();">매입처 거래원장상세</button>
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">관리부품</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-6">
													<input type="text" class="form-control width120px" id="mng_part_cnt" name="mng_part_cnt" value="" readonly="readonly">
												</div>
												<div class="col-6">
													<button type="button" class="btn btn-primary-gra" style="width: 75%;" onclick="javascript:fnSelectCustClientPartNoList();">상세내역</button>
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">주거래업체</th>
										<td>
											<input type="text" class="form-control width120px" id="main_deal_com_name" name="main_deal_com_name">
										</td>
									</tr>
								</tbody>
							</table>
						</div>
		<!-- /업체관리 -->
		<!-- 거래이력 -->
						<div class="col-4">
							<div class="title-wrap mt10">
								<h4>거래이력</h4>									
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">전전년도</th>
										<td>
											<input type="text" class="form-control width120px" id="dummy2" name="dummy2" readonly="readonly">
										</td>
									</tr>
									<tr>
										<th class="text-right">전년도</th>
										<td>
											<input type="text" class="form-control width120px" id="dummy3" name="dummy3" readonly="readonly">
										</td>
									</tr>
									<tr>
										<th class="text-right">당해년도</th>
										<td>
											<input type="text" class="form-control width120px" id="dummy4" name="dummy4" readonly="readonly">
										</td>
									</tr>
								</tbody>
							</table>
							<div class="title-wrap mt10">
								<h4>메모</h4>									
							</div>
							<div>
								<textarea class="form-control" id="memo" name="memo" style="height: 113px;"></textarea>
							</div>
						</div>
					</div>
		<!-- /거래이력 -->
		<!-- /하단 폼테이블 -->
					<div class="btn-group mt10"  style="width:75%;">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>						
			</div>		
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>