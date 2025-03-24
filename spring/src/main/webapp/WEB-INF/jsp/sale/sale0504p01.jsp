<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS리스트관리 > null > MS리스트상세
-- 작성자 : 성현우
-- 최초 작성일 : 2020-08-03 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		function goSave() {
			var frm = document.main_form;
			//validationcheck
			if($M.validation(frm,
					{field:["machine_ms_seq", "maker_cd", "maker_name", "sale_area_code", "area_disp"]})==false) {
				return;
			};

			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("저장이 완료되었습니다.");
							fnClose();
							window.opener.goSearch();
						}
					}
			);
		}
		
		// 메이커구분
		function goSearchMaker() {
			var params = {
				"parent_js_name" : "fnSetMaker"
			};
			var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=500, left=0, top=0";
			$M.goNextPage('/sale/sale0504p02', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		function fnSetMaker(data) {
			// alert(JSON.stringify(data));
			$M.setValue("maker_cd", data.maker_cd);
			$M.setValue("maker_name", data.maker_name);
		}
		
		// 지역구분
		function goSearchAddr() {
			var params = {
				"parent_js_name" : "fnSetAddr"
			};
			var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=500, left=0, top=0";
			$M.goNextPage('/sale/sale0504p03', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		function fnSetAddr(data) {
			// alert(JSON.stringify(data));
			$M.setValue("sale_area_code", data.sale_area_code);
			$M.setValue("area_disp", data.area_disp);
		}

		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="machine_ms_seq" name="machine_ms_seq" value="${result.machine_ms_seq}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">			
				<h4 class="primary">MS리스트상세</h4>				
			</div>
<!-- 폼테이블 -->					
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">연월</th>
							<td>
								<input type="text" id="ms_mon" name="ms_mon" class="form-control" readonly="readonly" dateFormat="yyyy-MM" value="${result.ms_mon}">
							</td>
							<th class="text-right">국가</th>
							<td>
								<input type="text" id="ms_nation" name="ms_nation" class="form-control" readonly="readonly" value="${result.ms_nation}">
							</td>	
							<th class="text-right">메이커명</th>
							<td>
								<input type="text" id="ms_maker_name" name="ms_maker_name" class="form-control" readonly="readonly" value="${result.ms_maker_name}">
							</td>						
						</tr>
						<tr>
							<th class="text-right">모델</th>
							<td>
								<input type="text" id="ms_machine_name" name="ms_machine_name" class="form-control" readonly="readonly" value="${result.ms_machine_name}">
							</td>
							<th class="text-right">중량</th>
							<td>
								<input type="text" id="ms_std_name" name="ms_std_name" class="form-control" readonly="readonly" value="${result.ms_std_name}">
							</td>	
							<th class="text-right">수량</th>
							<td>
								<input type="text" id="qty" name="qty" class="form-control" readonly="readonly" value="${result.qty}">
							</td>						
						</tr>
						<tr>
							<th class="text-right">시</th>
							<td>
								<input type="text" id="area_do" name="area_do" class="form-control" readonly="readonly" value="${result.area_do}">
							</td>
							<th class="text-right">군/구</th>
							<td>
								<input type="text" id="area_si" name="area_si" class="form-control" readonly="readonly" value="${result.area_si}">
							</td>	
							<th class="text-right">읍/면/동</th>
							<td>
								<input type="text" id="area_dong" name="area_dong" class="form-control" readonly="readonly" value="${result.area_dong}">
							</td>						
						</tr>
						<tr>
							<th class="text-right">기종명</th>
							<td colspan="3">
								<div class="form-row inline-pd">
									<div class="col-auto">
										<input type="text" id="ms_machine_type_cd" name="ms_machine_type_cd" class="form-control" readonly="readonly" value="${result.ms_machine_type_cd}">
									</div>
									<div class="col-auto">
										<input type="text" id="ms_machine_type_name" name="ms_machine_type_name" class="form-control" readonly="readonly" value="${result.ms_machine_type_name}">
									</div>
								</div>								
							</td>	
							<th class="text-right">규격명</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-auto">
										<input type="text" id="ms_machine_sub_type_cd" name="ms_machine_sub_type_cd" class="form-control" readonly="readonly" value="${result.ms_machine_sub_type_cd}">
									</div>
									<div class="col-auto">
										<input type="text" id="ms_machine_sub_type_name" name="ms_machine_sub_type_name" class="form-control" readonly="readonly" value="${result.ms_machine_sub_type_name}">
									</div>
								</div>	
							</td>						
						</tr>
						<tr>
							<th class="text-right">YK메이커명</th>
							<td>
								<div class="form-row inline-pd mb7">
									<div class="col-6">
										<input type="text" id="maker_cd" name="maker_cd" class="form-control" value="${result.maker_cd}" readonly="readonly">
									</div>
									<div class="col-auto">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchMaker();"><i class="material-iconssearch"></i></button>
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" id="maker_name" name="maker_name" class="form-control width215px" value="${result.maker_name}" readonly="readonly">
									</div>
								</div>
							</td>		
							<th class="text-right">지역명</th>
							<td colspan="3">
								<div class="form-row inline-pd mb7">
									<div class="col-auto">
										<input type="text" id="sale_area_code" name="sale_area_code"  class="form-control" value="${result.sale_area_code}" readonly="readonly">
									</div>
									<div class="col-auto">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchAddr();"><i class="material-iconssearch"></i></button>
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" id="area_disp" name="area_disp" class="form-control width215px" value="${result.area_disp}" readonly="readonly">
									</div>
								</div>
							</td>	
						</tr>
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	

<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->

</form>
</body>
</html>